module Forums
  class Thread < ApplicationRecord
    belongs_to :topic, optional: true
    belongs_to :created_by, class_name: 'User'

    has_many :posts, dependent: :destroy

    validates :title, presence: true, length: { in: 1..128 }
    validates :locked, inclusion: { in: [true, false] }
    validates :pinned, inclusion: { in: [true, false] }
    validates :hidden, inclusion: { in: [true, false] }

    scope :locked,   -> { where(locked: true) }
    scope :unlocked, -> { where(locked: false) }
    scope :pinned,   -> { where(pinend: true) }
    scope :hidden,   -> { where(hidden: true) }
    scope :visible,  -> { where(hidden: false) }

    before_create :update_depth
    before_update :update_depth, if: :topic_id_changed?

    after_initialize :set_defaults, unless: :persisted?

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

    def not_isolated?
      !topic || ancestors.empty? || ancestors.isolated.empty?
    end

    private

    def set_defaults
      if topic
        self.locked = topic.locked?
        self.hidden = topic.hidden? || topic.default_hidden?
      end
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
