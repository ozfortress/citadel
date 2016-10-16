require 'rails_helper'

shared_examples 'user_mailer/confirmation' do
  let(:user) { build(:user, confirmation_token: '123') }

  before do
    assign(:user, user)
  end

  it 'displays all data' do
    render

    expect(rendered).to include(user.name)
    expect(rendered).to include(confirm_user_email_url(token: user.confirmation_token))
  end
end

describe 'user_mailer/confirmation.html.haml' do
  include_examples 'user_mailer/confirmation'
end

describe 'user_mailer/confirmation.text.haml' do
  include_examples 'user_mailer/confirmation'
end
