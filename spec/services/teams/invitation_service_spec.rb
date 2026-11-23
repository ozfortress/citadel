require 'rails_helper'

describe Teams::InvitationService do
  let(:team) { create(:team) }
  let(:user) { create(:user) }
  let(:expiry_days) { Team::Invite::DEFAULT_EXPIRY.in_days.to_i }

  it 'successfully creates the invitation' do
    subject.call(team, user)

    expect(user.notifications.last.message).to include(team.name)
    expect(user.notifications.last.message).to include(expiry_days.to_s)
    expect(team.invited?(user)).to be(true)
    expect(user.notifications).to_not be_empty
  end
end
