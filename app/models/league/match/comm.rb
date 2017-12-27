class League
  class Match
    class Comm < ApplicationRecord
      include Paths
      include MarkdownRenderCaching
      include Users::DeletedBy

      belongs_to :created_by, class_name: 'User'
      belongs_to :match, class_name: 'Match'

      has_many :edits, class_name: 'CommEdit', dependent: :delete_all

      validates :content, presence: true, length: { in: 2..1_000 }
      caches_markdown_render_for :content

      delegate :home_team, to: :match
      delegate :away_team, to: :match
      delegate :league,    to: :match

      scope :ordered, -> { order(:created_at) }

      def create_edit!(user)
        CommEdit.create!(created_by: user, comm: self, content: content,
                         content_render_cache: content_render_cache)
      end

      paths do
        def show
          match_path(match, anchor: dom_id)
        end

        def destroy
          comm_path(id)
        end

        alias_method :update, :destroy

        def edit
          edit_comm_path(id)
        end

        def edits
          edits_for_comm_path(id)
        end

        def restore
          restore_comm_path(id)
        end
      end
    end
  end
end
