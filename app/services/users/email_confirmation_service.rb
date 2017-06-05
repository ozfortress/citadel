module Users
  module EmailConfirmationService
    include BaseService

    def send_email(user, flash)
      user.generate_confirmation_token
      UserMailer.confirmation(user).deliver

      flash[:notice] = "Sent confirmation email to #{user.email}. " \
                       'Please check your spam folder if the email has not reached your inbox.'
    end
  end
end
