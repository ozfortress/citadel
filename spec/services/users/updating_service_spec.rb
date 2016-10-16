require 'rails_helper'

describe Users::UpdatingService do
  let(:user) { create(:user) }

  before { ActionMailer::Base.deliveries.clear }

  it 'succesfully updates a user' do
    subject.call(user, description: 'A')

    user.reload
    expect(user.description).to eq('A')
  end

  it 'sends a confirmation email on new email set' do
    subject.call(user, email: 'foo@bar.com')

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    mail = ActionMailer::Base.deliveries.first
    expect(mail.to).to eq(['foo@bar.com'])
  end

  it 'sends a confirmation email on changed email' do
    user.update!(email: 'foo@bar.com')
    subject.call(user, email: 'bar@foo.com')

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    mail = ActionMailer::Base.deliveries.first
    expect(mail.to).to eq(['bar@foo.com'])
  end
end
