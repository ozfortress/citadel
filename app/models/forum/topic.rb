module Forum
  class Topic < ApplicationRecord
    belongs_to :parent_topic, class_name: 'Topic'
    belongs_to :created_by,   class_name: 'User'\

    has_many :child_topics, class_name: 'Topic', through: :parent_topic
    has_many :threads

    validates :created_by, presence: true
    validates :name, presence: true, length: { in: 1..128 }
  end
end
