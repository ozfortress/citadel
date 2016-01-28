class TeamInvitesController < ApplicationController
  before_action :require_invited

  def accept
    @invite.accept
    redirect_to user_path(current_user)
  end

  def decline
    @invite.decline
    redirect_to user_path(current_user)
  end

  private

  def require_invited
    @invite = TeamInvite.find(params[:id])
    redirect_to :root unless user_signed_in?
    redirect_to user_path(current_user) unless current_user == @invite.user
  end
end
