module Users
  module UpdatingService
    include BaseService

    def call(user, params, flash = {})
      user.transaction do
        user.assign_attributes(params)

        if user.valid?
          send_confirmation_email(user, flash) if user.email_changed? && !user.email.blank?
        end

        user.save || rollback!
      end
    end

    private

    def send_confirmation_email(user, flash)
      user.generate_confirmation_token
      UserMailer.confirmation(user).deliver

      flash[:notice] = "Sent confirmation email to #{user.email}. " \
                       'Please check your spam folder if the email has not reached your inbox.'
    end
  end
end
