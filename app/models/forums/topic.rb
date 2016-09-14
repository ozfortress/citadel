module Forums
  class Topic < ApplicationRecord
    has_ancestors :parent_topics, key: :parent_topic_id
    belongs_to :parent_topic, class_name: 'Topic', optional: true
    belongs_to :created_by,   class_name: 'User'

    has_many :child_topics, class_name: 'Topic', foreign_key: :parent_topic_id, dependent: :destroy
    has_many :threads,      dependent: :destroy

    validates :name, presence: true, length: { in: 1..128 }
    validates :locked,         inclusion: { in: [true, false] }
    validates :pinned,         inclusion: { in: [true, false] }
    validates :hidden,         inclusion: { in: [true, false] }
    validates :isolated,       inclusion: { in: [true, false] }
    validates :default_hidden, inclusion: { in: [true, false] }

    scope :locked,   -> { where(locked: true) }
    scope :unlocked, -> { where(locked: false) }
    scope :pinned,   -> { where(pinend: true) }
    scope :hidden,   -> { where(hidden: true) }
    scope :visible,  -> { where(hidden: false) }
    scope :isolated, -> { where(isolated: true) }

    before_create :update_depth
    before_update :update_depth!, if: :parent_topic_id_changed?

    def update_depth!
      update_column(:depth, update_depth)

      threads.each(&:update_depth!)
      child_topics.each(&:update_depth!)
    end

    private

    def update_depth
      self.depth = if parent_topic
                     parent_topic.depth + 1
                   else
                     0
                   end
    end
  end
end
