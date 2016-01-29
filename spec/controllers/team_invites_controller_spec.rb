require 'rails_helper'

describe TeamInvitesController do
  let(:user) { create(:user) }
  let(:team) { create(:team) }

  describe 'PATCH #accept' do
    it 'accepts an invite' do
      invite = team.invite(user)

      sign_in user
      patch :accept, id: invite.id

      expect(team.invited?(user)).to be(false)
      expect(team.on_roster?(user)).to be(true)
      expect(response).to redirect_to(user_path(user))
    end
  end

  describe 'PATCH #decline' do
    it 'declines an invite' do
      invite = team.invite(user)

      sign_in user
      patch :decline, id: invite.id

      expect(team.invited?(user)).to be(false)
      expect(team.on_roster?(user)).to be(false)
      expect(response).to redirect_to(user_path(user))
    end
  end
end
