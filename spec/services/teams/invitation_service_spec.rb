require 'rails_helper'

describe Teams::InvitationService do
  let(:team) { create(:team) }
  let(:user) { create(:user) }
  let(:expiry_days) { Team::Invite::DEFAULT_EXPIRY.in_days.to_i }

  it 'includes the expiry window in the notification' do
    subject.call(team, user)

    expect(user.notifications.last.message).to eq(
      "You have been invited to join the team: #{team.name}. This invite will expire in #{expiry_days} days."
    )
  end

  it 'still creates the invite and notification' do
    subject.call(team, user)
    expect(team.invited?(user)).to be(true)
    expect(user.notifications).to_not be_empty
  end
end
