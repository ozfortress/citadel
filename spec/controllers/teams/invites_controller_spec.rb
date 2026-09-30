require 'rails_helper'

describe Teams::InviteController do
  let(:user) { create(:user) }
  let(:captain) { create(:user) }
  let(:team) { create(:team) }

  before do
    captain.grant(:edit, team)
    allow(Rails.configuration.features).to receive(:team_invite_expiry_days).and_return(7)
  end

  describe 'POST #accept' do
    it 'accepts an invite that has not expired' do
      create(:team_invite, team:, user:, created_at: 1.day.ago)
      sign_in user

      post :accept, params: { team_id: team.id }

      expect(team.invited?(user)).to be(false)
      expect(team.on_roster?(user)).to be(true)
      expect(user.notifications).to be_empty
      expect(captain.notifications).to_not be_empty
      expect(response).to redirect_to(team_path(team))
    end

    it 'does not accept an expired invite' do
      create(:team_invite, team:, user:, created_at: 10.days.ago)
      sign_in user

      post :accept, params: { team_id: team.id }

      expect(team.invited?(user)).to be(false)
      expect(team.on_roster?(user)).to be(false)
      expect(user.notifications).to be_empty
      expect(captain.notifications).to be_empty
      expect(response).to redirect_to(root_path)
    end

    it 'does nothing if there is no invite' do
      sign_in user

      post :accept, params: { team_id: team.id }

      expect(team.invited?(user)).to be(false)
      expect(team.on_roster?(user)).to be(false)
      expect(user.notifications).to be_empty
      expect(captain.notifications).to be_empty
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'DELETE #decline' do
    it 'declines an invite' do
      create(:team_invite, team:, user:, created_at: 1.day.ago)
      sign_in user

      delete :decline, params: { team_id: team.id }

      expect(team.invited?(user)).to be(false)
      expect(team.on_roster?(user)).to be(false)
      expect(user.notifications).to be_empty
      expect(captain.notifications).to_not be_empty
      expect(response).to redirect_to(team_path(team))
    end
  end

  describe 'DELETE #revoke' do
    let(:invited) { create(:user) }

    before do
      create(:team_invite, team:, user: invited)
    end

    it 'revokes a pending invite for an admin' do
      user.grant(:edit, :teams)
      sign_in user

      delete :revoke, params: { team_id: team.id, user_id: invited.id }

      expect(team.invites.count).to eq(0)
      expect(response).to redirect_to(team_path(team))
    end

    it 'fails for a captain who is not an admin' do
      team.add_player!(user)
      user.grant(:edit, team)
      sign_in user

      delete :revoke, params: { team_id: team.id, user_id: invited.id }

      expect(team.invites.count).to eq(1)
      expect(response).to redirect_to(team_path(team))
    end

    it 'fails for unauthorized user' do
      sign_in user

      delete :revoke, params: { team_id: team.id, user_id: invited.id }

      expect(team.invites.count).to eq(1)
      expect(response).to redirect_to(team_path(team))
    end

    it 'fails for unauthenticated user' do
      delete :revoke, params: { team_id: team.id, user_id: invited.id }

      expect(team.invites.count).to eq(1)
      expect(response).to redirect_to(team_path(team))
    end

    it 'does nothing when the invite does not exist' do
      user.grant(:edit, :teams)
      sign_in user

      delete :revoke, params: { team_id: team.id, user_id: 0 }

      expect(team.invites.count).to eq(1)
      expect(response).to redirect_to(team_path(team))
    end
  end
end
