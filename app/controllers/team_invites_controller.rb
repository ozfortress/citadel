class TeamInvitesController < ApplicationController
  before_action :require_invited

  def accept
    @invite.accept
    redirect_to_back
  end

  def decline
    @invite.decline
    redirect_to_back
  end

  private

  def require_invited
    redirect_to :root unless user_signed_in?
    @invite = current_user.team_invites.find(params[:id])
  end
end
