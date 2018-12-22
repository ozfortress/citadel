class ApplicationController < ActionController::Base
  include ApplicationPermissions

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action do
    @notifications = current_user.notifications.order(created_at: :desc).load if user_signed_in?
  end

  after_action :track_user

  protected

  def require_login
    redirect_back(fallback_location: root_path) unless user_signed_in?
  end

  def track_user
    return unless user_signed_in?

    ip = request.remote_ip

    # Track ip address changes
    return unless session[:ip] != ip

    User::Log.log_user!(current_user, ip)
    session[:ip] = ip
  end
end
