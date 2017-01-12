module Leagues
  class TransfersController < ApplicationController
    include LeaguePermissions

    before_action only: [:index] { @league = League.find(params[:league_id]) }
    before_action except: [:index] do
      @transfer_request = League::Roster::TransferRequest.find(params[:id])
      @league = @transfer_request.league
    end

    before_action :require_user_league_permission

    def index
      @divisions = @league.divisions
                          .includes(transfer_requests: :user)
                          .references(:transfer_requests)
                          .merge(League::Roster::TransferRequest.order(:created_at))
    end

    def update
      Transfers::ApprovalService.call(@transfer_request)

      flash[:error] = @transfer_request.errors.full_messages.first
      index
      render :index
    end

    def destroy
      Transfers::DenialService.call(@transfer_request)

      flash[:error] = @transfer_request.errors.full_messages.first
      index
      render :index
    end

    private

    def require_user_league_permission
      redirect_to league_path(@league) unless user_can_edit_league?
    end
  end
end
