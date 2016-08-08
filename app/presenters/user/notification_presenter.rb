class User
  class NotificationPresenter < ActionPresenter::Base
    presents :notification

    def link
      link_to notification.message, read_notification_path(notification)
    end
  end
end
