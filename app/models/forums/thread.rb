module Forums
  class Thread < ApplicationRecord
    belongs_to :topic, optional: true
    belongs_to :created_by, class_name: 'User'

    has_many :posts

    validates :title, presence: true, length: { in: 1..128 }
  end
end
