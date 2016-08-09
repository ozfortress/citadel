module Leagues
  module Rosters
    class CommentsController < ApplicationController
      include ::LeaguePermissions

      before_action { @league = League.find(params[:league_id]) }
      before_action { @roster = @league.rosters.find(params[:roster_id]) }
      before_action :require_league_permissions

      def create
        params = comment_params
        params[:user] = current_user
        @comment = @roster.comments.create(params)

        redirect_to league_roster_path(@league, @roster)
      end

      private

      def comment_params
        params.require(:comment).permit(:content)
      end

      def require_league_permissions
        redirect_back(fallback_location: root_path) unless user_can_edit_league?
      end
    end
  end
end
