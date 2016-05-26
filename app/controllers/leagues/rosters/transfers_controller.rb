module Leagues
  module Rosters
    class TransfersController < ApplicationController
      include LeaguePermissions

      before_action { @competition = Competition.find(params[:league_id]) }
      before_action { @roster = @competition.rosters.find(params[:roster_id]) }
      before_action :require_roster_permission

      def show
        @transfer = @roster.transfers.new
      end

      def create
        @transfer = @roster.transfers.new(transfer_params)

        @transfer.save
        render :show
      end

      private

      def transfer_params
        params.require(:competition_transfer).permit(:user_id, :is_joining)
      end

      def require_roster_permission
        unless user_signed_in? && (current_user.can?(:edit, @roster.team) ||
                                   user_can_edit_league?)
          redirect_to league_roster_path(@competition, @roster)
        end
      end
    end
  end
end
