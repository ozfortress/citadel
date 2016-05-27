class NotificationsController < ApplicationController
  before_action { redirect_to_back unless user_signed_in? }
  before_action { @notification = current_user.notifications.find(params[:id]) }

  def read
    @notification.update!(read: true)
    redirect_to @notification.link
  end
end
