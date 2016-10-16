require 'rails_helper'

describe 'user_mailer/confirmation.text.haml' do
  let(:user) { build(:user, confirmation_token: '123') }

  before do
    assign(:user, user)
  end

  it 'displays' do
    render

    expect(rendered).to include(user.name)
    expect(rendered).to include(confirm_user_email_url(token: user.confirmation_token))
  end
end
