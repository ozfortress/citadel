module Leagues
  class TransfersController < ApplicationController
    include LeaguePermissions

    before_action { @league = League.find(params[:league_id]) }
    before_action except: [:index] do
      @transfer = @league.pending_transfers.find(params[:id])
    end

    before_action :require_user_league_permission

    def index
    end

    def update
      @transfer.update(approved: true)
      render :index
    end

    def destroy
      @transfer.delete
      render :index
    end

    private

    def require_user_league_permission
      redirect_to league_path(@league) unless user_can_edit_league?
    end
  end
end
