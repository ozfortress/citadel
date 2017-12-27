module Leagues
  module Matches
    class CommsController < ApplicationController
      include MatchesCommon

      before_action only: :create do
        @match = League::Match.find(params[:match_id])
        @league = @match.league
      end
      before_action only: [:edit, :update, :edits, :destroy, :restore] do
        @comm   = League::Match::Comm.find(params[:id])
        @match  = @comm.match
        @league = @match.league
      end
      before_action :require_user_can_comm, only: :create
      before_action :require_comm_exists_or_user_can_edit_league, only: [:edit, :update, :edits]
      before_action :require_user_can_edit_comm, only: [:edit, :update, :edits]
      before_action :require_user_can_edit_league, only: [:destroy, :restore]
      before_action :require_comm_exists, only: [:destroy, :update]
      before_action :require_comm_deleted, only: :restore

      def create
        @comm = Comms::CreationService.call(current_user, @match, comm_params)

        if @comm.valid?
          redirect_to @comm.paths.show
        else
          match_show_includes

          render '/leagues/matches/show'
        end
      end

      def edit
      end

      def update
        @comm = Comms::EditingService.call(current_user, @comm, comm_params)

        if @comm.valid?
          redirect_to @comm.paths.show
        else
          render :edit
        end
      end

      def edits
        @edits = @comm.edits.includes(:created_by)
      end

      def destroy
        @comm.delete!(current_user)
        redirect_to @comm.paths.show
      end

      def restore
        @comm.undelete!
        redirect_to @comm.paths.show
      end

      private

      def comm_params
        params.require(:comm).permit(:content)
      end

      def redirect_to_match
        redirect_to match_path(@match)
      end

      def redirect_to_comm
        redirect_to @comm.paths.show
      end

      def require_user_can_comm
        redirect_to_match unless user_can_comm?
      end

      def require_user_can_edit_comm
        redirect_to_comm unless user_can_edit_comm?(@comm)
      end

      def require_user_can_edit_league
        redirect_to_match unless user_can_edit_league?(@league)
      end

      def require_comm_exists_or_user_can_edit_league
        redirect_to_match unless user_can_edit_league?(@league) || @comm.exists?
      end

      def require_comm_exists
        redirect_to_match unless @comm.exists?
      end

      def require_comm_deleted
        redirect_to_match unless @comm.deleted?
      end
    end
  end
end
