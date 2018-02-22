module Leagues
  module Rosters
    class TransfersController < ApplicationController
      include TransferPermissions

      before_action do
        @roster = League::Roster.find(params[:roster_id])
        @league = @roster.league
      end
      before_action :require_transfer_permissions

      def create
        @transfer_request = Rosters::Transfers::CreationService.call(@roster, current_user, transfer_params)

        flash[:error] = @transfer_request.errors.full_messages.first unless @transfer_request.errors.empty?

        redirect_to edit_roster_path(@roster)
      end

      private

      def transfer_params
        params.require(:request).permit(:user_id, :is_joining)
      end

      def require_transfer_permissions
        redirect_to team_path(@roster.team) unless user_can_manage_transfers?
      end
    end
  end
end
