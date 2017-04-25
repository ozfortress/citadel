module Leagues
  module Matches
    class CommsController < ApplicationController
      include MatchesCommon

      before_action only: :create do
        @match = League::Match.find(params[:match_id])
        @league = @match.league
      end
      before_action only: [:edit, :update, :edits, :destroy] do
        @comm   = League::Match::Comm.find(params[:id])
        @match  = @comm.match
        @league = @match.league
      end
      before_action :require_user_can_comm, only: :create
      before_action :require_user_can_edit_comm, only: [:edit, :update, :edits]
      before_action :require_user_can_edit_league, only: :destroy

      def create
        @comm = Comms::CreationService.call(current_user, @match, comm_params)

        if @comm.valid?
          redirect_to match_path(@match)
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
          redirect_to match_path(@match)
        else
          render :edit
        end
      end

      def edits
        @edits = @comm.edits.includes(:user)
      end

      def destroy
        @comm.destroy!
        redirect_to match_path(@match)
      end

      private

      def comm_params
        params.require(:comm).permit(:content)
      end

      def require_user_can_comm
        redirect_to match_path(@match) unless user_can_comm?
      end

      def require_user_can_edit_comm
        redirect_to match_path(@match) unless user_can_edit_comm?(@comm)
      end

      def require_user_can_edit_league
        redirect_to match_path(@match) unless user_can_edit_league?(@league)
      end
    end
  end
end
