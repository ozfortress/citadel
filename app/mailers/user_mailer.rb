class UserMailer < ApplicationMailer
  def confirmation(user)
    @user = user

    mail(to: user.email, subject: 'Please confirm your email')
  end

  def notification(user, message, link)
    @user = user
    @message = message
    # 'root' links to the root_url if they're relative
    link = root_url + link[1..link.length] if link.starts_with?('/')
    @link = link

    @unsubscribe_link = edit_user_url(user)

    mail(to: user.email, subject: 'New Notification')
  end
end
