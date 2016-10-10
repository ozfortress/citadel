module Leagues
  class TransfersController < ApplicationController
    include LeaguePermissions

    before_action { @league = League.find(params[:league_id]) }
    before_action except: [:index] do
      @transfer_request = @league.transfer_requests.find(params[:id])
    end

    before_action :require_user_league_permission

    def index
      @transfer_requests = @league.transfer_requests
    end

    def update
      Transfers::ApprovalService.call(@transfer_request)

      index
      render :index
    end

    def destroy
      Transfers::DenialService.call(@transfer_request)

      index
      render :index
    end

    private

    def require_user_league_permission
      redirect_to league_path(@league) unless user_can_edit_league?
    end
  end
end
