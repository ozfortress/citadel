module Users
  module NameChangeHandlingService
    include BaseService

    def call(name_change, user, approve)
      name_change.transaction do
        name_change.approve(user, approve) || rollback!

        notify_user(name_change, name_change.user)
      end
    end

    private

    def notify_user(name_change, user)
      msg = notify_message(name_change)

      user.notify!(msg, user_path(user))
    end

    def notify_message(name_change)
      if name_change.approved_by
        "The request to change your name to '#{name_change.name}' was accepted!"
      else
        "The request to change your name to '#{name_change.name}' was denied."
      end
    end
  end
end
