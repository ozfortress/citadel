require 'rails_helper'

describe Team::Invite do
  let!(:expired_invite) { create(:team_invite, created_at: (Team::Invite::DEFAULT_EXPIRY + 1.day).ago) }
  let!(:invite) { create(:team_invite, created_at: (Team::Invite::DEFAULT_EXPIRY - 1.day).ago) }

  it { should belong_to(:user) }
  # it { should validate_uniqueness_of(:user).scoped_to(:team) }

  it { should belong_to(:team) }

  describe '.expired' do
    it 'only includes expired invites' do
      expect(Team::Invite.expired).to include(expired_invite)
      expect(Team::Invite.expired).not_to include(invite)
    end
  end
end
