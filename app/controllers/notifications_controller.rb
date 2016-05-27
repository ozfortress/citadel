class NotificationsController < ApplicationController
  before_action { @notification = current_user.notifications.find(params[:id]) }
  before_action :require_notification_belongs_to_user

  def read
    @notification.update!(read: true)
    redirect_to @notification.link
  end
end
