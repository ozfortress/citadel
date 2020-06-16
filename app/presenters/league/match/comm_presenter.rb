class League
  class Match
    class CommPresenter < BasePresenter
      presents :comm

      def user_roster
        @user_roster ||=
          if comm.match.home_team.on_roster?(comm.created_by)
            comm.match.home_team
          elsif comm.match.away_team.on_roster?(comm.created_by)
            comm.match.away_team
          end
      end

      def user_team
        user_roster&.team
      end

      def created_at
        comm.created_at.strftime('%c')
      end

      def created_at_in_words
        time_ago_in_words comm.created_at
      end

      def last_edited
        comm.updated_at.strftime('%c')
      end

      def last_edited_in_words
        time_ago_in_words comm.updated_at
      end

      def deleted_at
        comm.deleted_at.strftime('%c')
      end

      def created_by
        @created_by ||= present(comm.created_by)
      end

      def deleted_by
        @deleted_by ||= present(comm.deleted_by)
      end

      def content
        # rubocop:disable Rails/OutputSafety
        comm.content_render_cache.html_safe
        # rubocop:enable Rails/OutputSafety
      end
    end
  end
end
