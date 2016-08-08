module Leagues
  module Rosters
    class TransfersController < ApplicationController
      include TransferPermissions

      before_action { @league = League.find(params[:league_id]) }
      before_action { @roster = @league.rosters.find(params[:roster_id]) }
      before_action :require_transfer_permissions

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
        params.require(:transfer).permit(:user_id, :is_joining)
      end

      def require_transfer_permissions
        redirect_to league_roster_path(@league, @roster) unless user_can_manage_transfers?
      end
    end
  end
end
