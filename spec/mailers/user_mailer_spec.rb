require 'rails_helper'

describe UserMailer do
  let(:user) { build(:user, email: 'foo@bar.com', confirmation_token: '123') }
  let(:mail) { described_class.confirmation(user).deliver_now }

  it 'sets the subject' do
    expect(mail.subject).to eq('Please confirm your email')
  end

  it 'sends to the user' do
    expect(mail.to).to eq([user.email])
  end
end
