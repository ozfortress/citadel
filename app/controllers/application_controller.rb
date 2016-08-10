class ApplicationController < ActionController::Base
  include ApplicationPermissions

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_filter :track_action

  protected

  def require_login
    redirect_back(fallback_location: root_path) unless user_signed_in?
  end

  def track_action
    ahoy.track "#{controller_name}##{action_name}", request.filtered_parameters
  end
end
