module Forums
  class Topic < ApplicationRecord
    has_ancestors :parent_topics, key: :parent_topic_id
    belongs_to :parent_topic, class_name: 'Topic', optional: true
    belongs_to :created_by,   class_name: 'User'

    has_many :child_topics, class_name: 'Topic', foreign_key: :parent_topic_id
    has_many :threads

    validates :name, presence: true, length: { in: 1..128 }
  end
end
