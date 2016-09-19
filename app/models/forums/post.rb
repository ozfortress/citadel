module Forums
  class Post < ApplicationRecord
    belongs_to :thread
    belongs_to :created_by, class_name: 'User'

    has_many :edits, class_name: 'PostEdit', dependent: :delete_all

    validates :content, presence: true
  end
end
