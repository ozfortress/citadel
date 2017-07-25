module Users
  class LogsController < ApplicationController
    include ::UsersPermissions

    before_action { @user = User.find(params[:user_id]) }
    before_action :require_user_permissions

    def show
      ip_visit_ids = @user.distinct_ips.select(:id).map(&:id)
      @visits = Visit.where(id: ip_visit_ids).order(started_at: :desc)
    end

    def alts
      @visits = @user.distinct_ips.select(:started_at)
      @matching_visits = @visits.map { |visit| [visit.ip, visit] }.to_h

      @alts = Visit.select('DISTINCT ON(user_id) user_id, *')
                   .reorder(:user_id)
                   .where(ip: @visits.map(&:ip))
                   .where.not(user: @user)
                   .includes(:user)
    end

    private

    def require_user_permissions
      redirect_back(fallback_location: root_path) unless user_can_edit_users?
    end
  end
end
