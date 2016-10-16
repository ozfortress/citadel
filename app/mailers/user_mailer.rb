class UserMailer < ApplicationMailer
  def confirmation(user)
    @user = user

    mail(to: user.email, subject: 'Please confirm your email')
  end
end
