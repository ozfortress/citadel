module Users
  module NotificationService
    include BaseService

    def call(user, message, url)
      user.transaction do
        user.notify!(message, url)

        UserMailer.notification(user, message, url).deliver if user.confirmed?
      end
    end
  end
end
