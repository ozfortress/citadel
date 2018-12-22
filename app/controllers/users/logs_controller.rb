module Users
  class LogsController < ApplicationController
    include ::UsersPermissions

    before_action do
      @user = User.find(params[:user_id])
      @logs = @user.logs.order(last_seen_at: :desc)
    end
    before_action :require_user_permissions

    def show
    end

    def alts
      @logs_map = @logs.index_by(&:ip)

      @alt_logs = User::Log.select('DISTINCT ON(user_id) user_id, *')
                           .reorder(:user_id)
                           .where(ip: @logs.map(&:ip))
                           .where.not(user: @user)
                           .includes(:user)
    end

    private

    def require_user_permissions
      redirect_back(fallback_location: root_path) unless user_can_edit_users?
    end
  end
end
