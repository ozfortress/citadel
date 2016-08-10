class AdminController < ApplicationController
  before_action :require_any_admin_permissions

  def index
  end

  def logs
    timeframe = 4.hours
    events_in_timeframe = Ahoy::Event.where(time: timeframe.ago..Time.now)
    @events_per_second = events_in_timeframe.count / timeframe.to_f
    @users_count = User.count
    @teams_count = Team.count
    @matches_count = League::Match.count
    @match_comms_count = League::Match::Comm.count
    @events = Ahoy::Event.search(params[:q]).paginate(page: params[:page])
  end

  private

  def require_any_admin_permissions
    redirect_to root_path unless user_signed_in? && current_user.admin?
  end
end
