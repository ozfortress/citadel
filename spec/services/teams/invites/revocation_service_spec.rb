require 'rails_helper'

describe Teams::Invites::RevocationService do
  let(:team) { create(:team) }
  let(:captain) { create(:user) }
  let(:invited) { create(:user) }
  let(:invite) { create(:team_invite, team:, user: invited) }

  before do
    captain.grant(:edit, team)
  end

  it 'destroys the invite' do
    subject.call(invite)

    expect(invite).to be_destroyed
    expect(team.invites).to be_empty
    expect(captain.notifications).to_not be_empty
    expect(invited.notifications).to_not be_empty
  end
end
