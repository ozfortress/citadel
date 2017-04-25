module Leagues
  module Rosters
    class CommentsController < ApplicationController
      include ::LeaguePermissions

      before_action do
        @roster = League::Roster.find(params[:roster_id])
        @league = @roster.league
      end
      before_action :require_league_permissions

      def create
        params = comment_params
        params[:user] = current_user
        @comment = @roster.comments.create(params)

        redirect_to edit_roster_path(@roster)
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
