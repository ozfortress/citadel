module Users
  class NotificationsController < ApplicationController
    before_action :require_login
    before_action { @notification = current_user.notifications.find(params[:id]) }

    def read
      @notification.update!(read: true)
      redirect_to @notification.link
    end
  end
end
