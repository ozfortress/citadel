module Teams
  class InviteController < ApplicationController
    include TeamPermissions

    before_action do
      @team = Team.find(params[:team_id])
    end

    before_action except: :revoke do
      @invite = @team.invite_for(current_user)
    end

    before_action :require_invited, except: :revoke
    before_action :require_can_edit_teams, only: :revoke

    def accept
      Invites::AcceptanceService.call(@invite)
      redirect_back
    end

    def decline
      Invites::DeclanationService.call(@invite)
      redirect_back
    end

    def revoke
      invite = @team.invites.find_by(user_id: params[:user_id])
      Invites::RevocationService.call(invite) if invite.present?
      redirect_back
    end

    private

    def require_invited
      redirect_to :root unless user_signed_in? && @invite.present?
    end

    def redirect_back
      super(fallback_location: team_path(@team))
    end

    def require_can_edit_teams
      redirect_to team_path(@team) unless user_can_edit_teams?
    end
  end
end
