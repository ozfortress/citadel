module Leagues
  module Rosters
    class CommentsController < ApplicationController
      include ::LeaguePermissions

      before_action do
        @roster = League::Roster.find(params[:roster_id])
        @league = @roster.league
      end

      before_action only: [:edit, :update, :edits, :destroy, :restore] do
        @comment = @roster.comments.find(params[:id])
      end

      before_action :require_league_permissions

      def create
        @comment = Comments::CreationService.call(current_user, @roster, comment_params)

        redirect_to edit_roster_path(@roster)
      end

      def edit
      end

      def update
        @comment = Comments::EditingService.call(current_user, @comment, comment_params)

        if @comment.valid?
          redirect_to edit_roster_path(@roster)
        else
          render :edit
        end
      end

      def edits
        @edits = @comment.edits.includes(:created_by)
      end

      def destroy
        @comment.delete!(current_user)
        redirect_to edit_roster_path(@roster)
      end

      def restore
        @comment.undelete!
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
