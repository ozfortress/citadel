module Forum
  class Post < ApplicationRecord
    belongs_to :thread
    belongs_to :created_by, class_name: 'User'

    validates :thread, presence: true
    validates :created_by, presence: true
    validates :content, presence: true
  end
end
