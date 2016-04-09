class ApplicationController < ActionController::Base
  include ApplicationPermissions

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def require_login
    redirect_to_back unless user_signed_in?
  end

  private

  def redirect_to_back(default = root_path)
    if request.referer.present?
      redirect_to :back
    else
      redirect_to default
    end
  end
end
