require 'rails_helper'

shared_examples 'user_mailer/notification' do
  let(:user) { build(:user, confirmation_token: '123') }
  let(:message) { 'Notification Message' }
  let(:link) { 'Notification Link' }

  before do
    assign(:user, user)
    assign(:message, message)
    assign(:link, link)
  end

  it 'displays all data' do
    render

    expect(rendered).to include(user.name)
    expect(rendered).to include(message)
    expect(rendered).to include(link)
  end
end

describe 'user_mailer/notification.html.haml' do
  include_examples 'user_mailer/notification'
end

describe 'user_mailer/notification.text.haml' do
  include_examples 'user_mailer/notification'
end
