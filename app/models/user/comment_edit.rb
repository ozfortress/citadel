class User
  class CommentEdit < ApplicationRecord
    include MarkdownRenderCaching

    belongs_to :created_by, class_name: 'User'
    belongs_to :comment, class_name: 'Comment'

    validates :content, presence: true
    caches_markdown_render_for :content
  end
end
