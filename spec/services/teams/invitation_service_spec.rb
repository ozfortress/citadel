require 'rails_helper'

describe Teams::InvitationService do
  let(:team) { create(:team) }
  let(:user) { create(:user) }

  before do
    allow(Rails.configuration.features).to receive(:team_invite_expiry_days).and_return(7)
  end

  it 'includes the expiry window when the expiry is enabled' do
    subject.call(team, user)

    expect(user.notifications.last.message).to eq(
      "You have been invited to join the team: #{team.name}. This invite will expire in 7 days."
    )
  end

  it 'uses the singular when expiry is one day' do
    allow(Rails.configuration.features).to receive(:team_invite_expiry_days).and_return(1)
    subject.call(team, user)
    expect(user.notifications.last.message).to eq(
      "You have been invited to join the team: #{team.name}. This invite will expire in 1 day."
    )
  end

  it 'does not include the expiry window when the expiry is disabled' do
    allow(Rails.configuration.features).to receive(:team_invite_expiry_days).and_return(0)
    subject.call(team, user)
    expect(user.notifications.last.message).to eq(
      "You have been invited to join the team: #{team.name}."
    )
  end

  it 'still creates the invite and notification' do
    subject.call(team, user)
    expect(team.invited?(user)).to be(true)
    expect(user.notifications).to_not be_empty
  end
end
