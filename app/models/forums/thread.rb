module Forums
  class Thread < ApplicationRecord
    belongs_to :topic, optional: true, inverse_of: :threads
    belongs_to :created_by, class_name: 'User'

    has_many :posts,         dependent: :destroy
    has_many :subscriptions, dependent: :destroy

    has_many :post_creators, through: :posts, source: :created_by
    validates :title, presence: true, length: { in: 1..128 }
    validates :locked, inclusion: { in: [true, false] }
    validates :pinned, inclusion: { in: [true, false] }
    validates :hidden, inclusion: { in: [true, false] }

    scope :ordered, -> { order(created_at: :desc) }

    scope :locked,   -> { where(locked: true) }
    scope :unlocked, -> { where(locked: false) }
    scope :pinned,   -> { where(pinned: true) }
    scope :hidden,   -> { where(hidden: true) }
    scope :visible,  -> { where(hidden: false) }

    counter_culture :topic,
                    column_name: proc { |model| model.visible? ? 'visible_threads_count' : nil },
                    column_names: {
                      'NOT forums_threads.hidden' => 'visible_threads_count',
                      'forums_threads.hidden' => nil,
                    }

    before_create :update_depth
    before_update :update_depth, if: :topic_id_changed?

    after_initialize :set_defaults, unless: :persisted?

    before_update do
      if hidden_changed?
        sign = hidden? ? :- : :+
        ActiveRecord::Base.connection.exec_update(<<-SQL, 'SQL', [[nil, id]])
          UPDATE users
          SET public_forums_posts_count = public_forums_posts_count #{sign} (
            SELECT COUNT(1) FROM forums_posts WHERE thread_id = $1 AND created_by_id = users.id)
          WHERE id IN (SELECT DISTINCT users.id FROM users
                       INNER JOIN forums_posts ON users.id = forums_posts.created_by_id
                       WHERE thread_id = $1)
        SQL
      end
    end

    def ancestors
      if topic
        Topic.where(id: topic.id).union(topic.ancestors)
      else
        []
      end
    end

    def path
      if topic
        topic.ancestors + [topic]
      else
        []
      end
    end

    def isolated?
      if topic.nil?
        false
      else
        topic.isolated?
      end
    end

    def not_isolated?
      !isolated?
    end

    def isolated_by
      topic&.isolated_by
    end

    def visible?
      !hidden?
    end

    def original_post
      posts.reorder(created_at: :asc).first
    end

    def latest_post
      posts.reorder(created_at: :desc).first
    end

    self.per_page = 20

    private

    def set_defaults
      return unless topic

      self.pinned = false if pinned.nil?

      self.locked = topic.default_locked? if locked.nil?

      self.hidden = topic.hidden? || topic.default_hidden? if hidden.nil?
    end

    def update_depth
      self.depth = if topic
                     topic.depth + 1
                   else
                     0
                   end
    end
  end
end
