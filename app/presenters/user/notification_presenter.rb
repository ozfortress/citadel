class User
  class NotificationPresenter < BasePresenter
    presents :notification

    def link(options = {})
      link_to notification.message, notification_path(notification), options
    end
  end
end
