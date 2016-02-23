class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  http_basic_authenticate_with name: 'ozf', password: 'ozf' unless Rails.env.test?

  protected

  def require_login
    redirect_to :back unless user_signed_in?
  end

  helper_method :user_can_meta?
  def user_can_meta?
    user_signed_in? && current_user.can?(:edit, :games)
  end
end
