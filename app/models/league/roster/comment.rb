class League
  class Roster
    class Comment < ApplicationRecord
      include MarkdownRenderCaching

      belongs_to :user
      belongs_to :roster, class_name: 'Roster'

      validates :content, presence: true
      caches_markdown_render_for :content
    end
  end
end
