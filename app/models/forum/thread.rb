module Forum
  class Thread < ApplicationRecord
    belongs_to :topic
    belongs_to :created_by, class_name: 'User'

    has_many :posts

    validates :title, presence: true, length: { in: 1..128 }
  end
end
