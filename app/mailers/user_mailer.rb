class UserMailer < ApplicationMailer
  def confirmation(user)
    @user = user

    mail(to: user.email, subject: 'Please confirm your email')
  end

  def notification(user, message, link)
    @user = user
    @message = message
    if link.starts_with?('/')
      link = root_url + link[1..link.length]
    end
    @link = link

    mail(to: user.email, subject: 'New Notification')
  end
end
