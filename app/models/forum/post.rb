module Forum
  class Post < ApplicationRecord
    belongs_to :thread
    belongs_to :created_by, class_name: 'User'

    validates :content, presence: true
  end
end
