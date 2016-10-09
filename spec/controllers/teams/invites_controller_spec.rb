require 'rails_helper'

describe Teams::InviteController do
  let(:user) { create(:user) }
  let(:captain) { create(:user) }
  let(:team) { create(:team) }

  before do
    captain.grant(:edit, team)
  end

  describe 'POST #accept' do
    it 'accepts an invite' do
      team.invite(user)
      sign_in user

      post :accept, params: { team_id: team.id }

      expect(team.invited?(user)).to be(false)
      expect(team.on_roster?(user)).to be(true)
      expect(user.notifications).to be_empty
      expect(captain.notifications).to_not be_empty
      expect(response).to redirect_to(team_path(team))
    end
  end

  describe 'DELETE #decline' do
    it 'declines an invite' do
      team.invite(user)
      sign_in user

      delete :decline, params: { team_id: team.id }

      expect(team.invited?(user)).to be(false)
      expect(team.on_roster?(user)).to be(false)
      expect(user.notifications).to be_empty
      expect(captain.notifications).to_not be_empty
      expect(response).to redirect_to(team_path(team))
    end
  end
end
