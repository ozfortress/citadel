class User
  class NotificationPresenter < BasePresenter
    presents :notification

    def link(options = {})
      link_to notification.message, notification_path(notification), options
    end

    def created_at
      notification.created_at.strftime('%c')
    end

    def created_at_in_words
      time_ago_in_words notification.created_at
    end
  end
end
