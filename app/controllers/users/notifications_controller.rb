module Users
  class NotificationsController < ApplicationController
    before_action :require_login

    before_action except: :clear do
      @notification = current_user.notifications.find(params[:id])
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
