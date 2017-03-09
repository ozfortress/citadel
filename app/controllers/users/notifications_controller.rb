module Users
  class NotificationsController < ApplicationController
    before_action :require_login

    before_action only: :read do
      @notification = current_user.notifications.find(params[:id])
    end
    before_action only: :index do
      @notifications = current_user.notifications.unread
    end
    skip_after_action :track_action, only: :index

    def index
      render '/application/notifications-ajax'
    end

    def clear
      if current_user.notifications.unread.update(read: true)
        redirect_back(fallback_location: root_path)
      end
    end

    def read
      @notification.update!(read: true)
      redirect_to @notification.link
    end
  end
end
