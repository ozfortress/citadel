module Users
  module NotificationService
    include BaseService

    def call(user, params)
      notification = user.notifications.new(params)

      user.transaction do
        notification.save || rollback!

        UserMailer.notification(user, notification.message, notification.link).deliver if user.confirmed?
      end

      notification
    end
  end
end
