module Teams
  class InviteController < ApplicationController
    before_action do
      @team = Team.find(params[:team_id])
      @invite = @team.invite_for(current_user)
    end

    before_action :require_invited

    def accept
      Invites::AcceptanceService.call(@invite)
      redirect_back
    end

    def decline
      Invites::DeclanationService.call(@invite)
      redirect_back
    end

    private

    def require_invited
      redirect_to :root unless user_signed_in?
    end

    def redirect_back
      super(fallback_location: team_path(@team))
    end
  end
end
