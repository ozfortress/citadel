class User
  class Comment < ApplicationRecord
    include MarkdownRenderCaching

    belongs_to :user
    belongs_to :created_by, class_name: 'User'

    validates :content, presence: true
    caches_markdown_render_for :content
  end
end
