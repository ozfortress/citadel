class PermissionsController < ApplicationController
  before_action except: :index do
    @action = params.require(:action_).to_sym
    @subject = params.require(:subject).to_sym

    @target = if subject?
                @subject.to_s.camelize.constantize.find(params[:target])
              else
                @subject
              end
  end

  before_action only: [:grant, :revoke] do
    @user = target_users.find(params.require(:user_id))
  end

  before_action :require_login
  before_action :ensure_valid_target, except: :index
  before_action :require_permission, except: :index

  def index
    @grants = User.grants
  end

  def users
    users_which_can = User.which_can(@action, @target)
    @users_with_permission = users_which_can.search(params[:q])

    excluded_users = users_which_can.select(:id)
    @users_without_permission = target_users.search(params[:q])
                                            .where('users.id NOT IN (?)', excluded_users)
                                            .paginate(page: params[:page])
  end

  def grant
    @user.grant(@action, @target)
    redirect_back
  end

  def revoke
    @user.revoke(@action, @target)
    redirect_back
  end

  private

  def subject?
    User.grants[@action][@subject].subject?
  end

  def target_users
    if @target.is_a? Team
      @target.users
    else
      User.all
    end
  end

  def require_permission
    redirect_back unless current_user.can?(:edit, :permissions) ||
                         current_user.can?(@action, @target)
  end

  def ensure_valid_target
    redirect_back if subject? && ![:team].include?(@subject)
  end

  def redirect_back(options = {})
    super({ fallback_location: permissions_path }.merge(options))
  end
end
