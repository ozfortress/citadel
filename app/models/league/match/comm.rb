class League
  class Match
    class Comm < ApplicationRecord
      include MarkdownRenderCaching

      belongs_to :user
      belongs_to :match, class_name: 'Match'

      has_many :edits, class_name: 'CommEdit', dependent: :delete_all

      validates :content, presence: true, length: { in: 2..1_000 }
      caches_markdown_render_for :content

      delegate :home_team, to: :match
      delegate :away_team, to: :match
      delegate :league,    to: :match

      def create_edit!(user)
        CommEdit.create!(user: user, comm: self, content: content,
                         content_render_cache: content_render_cache)
      end
    end
  end
end
