require 'rails_helper'

describe Users::NotificationService do
  let(:user) { create(:user) }

  before { ActionMailer::Base.deliveries.clear }

  it 'notifies a user' do
    subject.call(user, message: 'msg', link: 'link')

    expect(user.notifications.size).to eq(1)
    notification = user.notifications.first
    expect(notification.user).to eq(user)
    expect(notification.message).to eq('msg')
    expect(notification.link).to eq('link')
  end

  it 'sends an email for confirmed user emails' do
    user.update!(email: 'foo@bar.com', confirmed_at: Time.current)

    subject.call(user, message: 'msg', link: 'link')

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    mail = ActionMailer::Base.deliveries.first
    expect(mail.to).to eq([user.email])
  end

  it "doesn't send an email for unconfirmed user emails" do
    user.update!(email: 'foo@bar.com')

    subject.call(user, message: 'msg', link: 'link')

    expect(ActionMailer::Base.deliveries).to be_empty
  end
end
