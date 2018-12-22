class AdminController < ApplicationController
  before_action :require_any_admin_permissions

  def index
  end

  def statistics
    @users_count = User.count
    @api_keys_count = APIKey.count
    @teams_count = Team.count
    @matches_count = League::Match.count
    @match_comms_count = League::Match::Comm.count
    @match_comm_edits_count = League::Match::CommEdit.count - @match_comms_count
  end

  private

  def require_any_admin_permissions
    redirect_to root_path unless user_signed_in? && current_user.admin?
  end
end
