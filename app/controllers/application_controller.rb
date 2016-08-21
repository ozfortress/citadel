class ApplicationController < ActionController::Base
  include ApplicationPermissions

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :get_notifications

  after_action :track_action

  protected

  def require_login
    redirect_back(fallback_location: root_path) unless user_signed_in?
  end

  def get_notifications
    if user_signed_in?
      @notifications = current_user.notifications.unread
    end
  end

  def track_action
    ahoy.track "#{controller_name}##{action_name}", request.filtered_parameters
  end
end
