class PermissionsController < ApplicationController
  before_action except: :index do
    @action = params.require(:action_).to_sym
    @subject = params.require(:subject).to_sym
  end

  before_action only: [:grant, :revoke] do
    @user = User.find(params.require(:user_id))
  end

  before_action :require_login
  before_action :require_permission, except: :index

  def index
    @permissions = User.permissions
  end

  def users
    @users = User.search_all(params[:q]).paginate(page: params[:page])
  end

  def grant
    @user.grant(@action, @subject)
    redirect_to_back
  end

  def revoke
    @user.revoke(@action, @subject)
    redirect_to_back
  end

  private

  def require_permission
    redirect_to_back unless current_user.can?(:edit, :permissions) ||
                            current_user.can?(@action, @subject)
  end
end
