class League
  class Roster
    class CommentEdit < ApplicationRecord
      default_scope { order(created_at: :desc) }

      belongs_to :created_by, class_name: 'User'
      belongs_to :comment, class_name: 'Comment'

      validates :content, presence: true
    end
  end
end
