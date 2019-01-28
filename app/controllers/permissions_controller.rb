class PermissionsController < ApplicationController
  # Include a bunch of permission models
  include Forums::Permissions
  include TeamPermissions

  before_action except: :index do
    @action = params.require(:action_).to_sym
    @subject = params.require(:subject).to_sym

    @target = if subject?
                User.grant_model_for(@action, @subject).subject_cls.find(params[:target])
              else
                @subject
              end
  end

  before_action :require_login
  before_action :ensure_valid_target, except: :index
  before_action :require_permission, except: :index

  def index
    @grants = User.grant_models
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
    user = target_users.find(params.require(:user_id))
    user.grant(@action, @target)
    redirect_back
  end

  def revoke
    user = User.find(params.require(:user_id))
    user.revoke(@action, @target)
    redirect_back
  end

  private

  def subject?
    User.grant_models[@action][@subject].subject?
  end

  def target_users
    if @target.is_a? Team
      @target.users
    else
      User.all
    end
  end

  def admin_subject
    if subject?
      @subject.to_s.pluralize.to_sym
    else
      @subject
    end
  end

  def require_permission
    if subject?
      redirect_back unless user_can_edit_permissions?
    else
      redirect_back unless current_user.can?(:edit, :permissions) || current_user.can?(@action, admin_subject)
    end
  end

  def user_can_edit_permissions?
    case @target
    when Team
      user_can_edit_team?(@target)
    when Forums::Topic
      user_can_manage_topic?(@target)
    else raise('Unknown permission target')
    end
  end

  def ensure_valid_target
    redirect_back if subject? && ![:team, :forums_topic].include?(@subject)
  end

  def redirect_back(options = {})
    super({ fallback_location: permissions_path }.merge(options))
  end
end
