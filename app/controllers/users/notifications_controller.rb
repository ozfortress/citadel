module Users
  class NotificationsController < ApplicationController
    include UsersPermissions

    before_action :require_login

    before_action only: [:show, :destroy] do
      @notification = current_user.notifications.find(params[:id])
    end

    before_action only: [:create] do
      @user = User.find(params[:user_id])
    end

    before_action :require_users_permission, only: [:create]

    def index
      render :index, formats: [:js]
    end

    def create
      @notification = Users::NotificationService.call(@user, notification_params)

      if @notification.persisted?
        flash[:notice] = 'Notification was sent!'
      else
        flash[:error] = 'Failed to send notification.'
      end

      redirect_to(edit_user_path(@user))
    end

    def clear
      @notifications.destroy_all
      index
    end

    def show
      @notification.update!(read: true)
      redirect_to @notification.link
    end

    def destroy
      @notification.destroy
      index
    end

    private

    def notification_params
      params.require(:notification).permit(:message, :link)
    end

    def require_users_permission
      redirect_to user_path(@user) unless user_can_edit_users?
    end
  end
end
