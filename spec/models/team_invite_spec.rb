require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe TeamInvite do
  let!(:invite) { create(:team_invite) }

  it { should belong_to(:user) }
  it { should belong_to(:team) }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:team) }

  it 'notifies user on creation' do
    expect(invite.user.notifications).to_not be_empty
  end

  it 'notifies captains on destruction' do
    cap1 = create(:user)
    cap1.grant(:edit, invite.team)
    cap2 = create(:user)
    cap2.grant(:edit, invite.team)

    invite.destroy!

    expect(cap1.notifications).to_not be_empty
    expect(cap2.notifications).to_not be_empty
  end
end
