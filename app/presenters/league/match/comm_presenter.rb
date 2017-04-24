class League
  class Match
    class CommPresenter < ActionPresenter::Base
      presents :comm

      def id
        "comm_#{comm.id}"
      end

      def user_roster
        @user_roster ||=
          if comm.match.home_team.on_roster?(comm.user)
            comm.match.home_team
          elsif comm.match.away_team.on_roster?(comm.user)
            comm.match.away_team
          end
      end

      def user_team
        user_roster&.team
      end

      def anchor_path
        match_path(comm.match, anchor: id)
      end

      def edit_path
        edit_comm_path(comm)
      end

      def edits_path
        edits_for_comm_path(comm)
      end

      def created_at
        comm.created_at.strftime('%c')
      end

      def content
        # rubocop:disable Rails/OutputSafety
        comm.content_render_cache.html_safe
        # rubocop:enable Rails/OutputSafety
      end
    end
  end
end
