module Users
  module UpdatingService
    include BaseService

    def call(user, params, flash = {})
      user.transaction do
        user.assign_attributes(params)

        EmailConfirmationService.send_email(user, flash) if user.valid? && user.email_changed? && user.email?

        user.save || rollback!
      end
    end
  end
end
