require 'rails_helper'

describe TeamsController do
  let(:user) { create(:user) }

  describe 'GET #index' do
    before do
      create_list(:team, 50)
    end

    it 'succeeds' do
      get :index

      expect(response).to have_http_status(:success)
    end

    it 'succeeds with search' do
      get :index, params: { q: 'foo' }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'succeeds' do
      sign_in user

      get :new

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'creates a team' do
      sign_in user
      post :create, params: { team: { name: 'A', description: 'B' } }

      team = Team.find_by(name: 'A')
      expect(team).to_not be_nil
      expect(team.description).to eq('B')
      expect(team.on_roster?(user)).to be(true)
      expect(user.can?(:edit, team)).to be(true)
    end

    it 'handles duplicate teams' do
      create(:team, name: 'A')

      sign_in user
      post :create, params: { team: { name: 'A', description: 'B' } }
    end
  end

  describe 'GET #show' do
    it 'succeeds' do
      team = create(:team)

      get :show, params: { id: team.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'succeeds' do
      team = create(:team)
      user.grant(:edit, team)

      sign_in user
      get :edit, params: { id: team.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    it 'updates a team' do
      team = create(:team, name: 'A', description: 'B')
      user.grant(:edit, team)

      sign_in user
      patch :update, params: { id: team.id, team: { name: 'C', description: 'D' } }

      team = Team.find(team.id)
      expect(team.name).to eq('C')
      expect(team.description).to eq('D')
    end
  end

  describe 'GET #recruit' do
    before { create_list(:user, 50) }

    it 'succeeds' do
      team = create(:team)
      user.grant(:edit, team)

      sign_in user
      get :recruit, params: { id: team.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #invite' do
    it 'invites a player to a team' do
      team = create(:team)
      invited = create(:user)
      user.grant(:edit, team)

      sign_in user
      patch :invite, params: { id: team.id, user_id: invited.id }

      invite = invited.team_invites.first
      expect(invite).to_not be_nil
      expect(invite.user).to eq(invited)
      expect(invite.team).to eq(team)
      expect(team.invited?(invited)).to be(true)
    end
  end

  describe 'PATCH #leave' do
    it 'removes a player from a team' do
      team = create(:team)
      team.add_player!(user)

      sign_in user
      request.env['HTTP_REFERER'] = '/'
      patch :leave, params: { id: team.id }

      expect(team.on_roster?(user)).to be(false)
      expect(team.invited?(user)).to be(false)
    end

    it 'kicks a player from a team' do
      team = create(:team)
      player = create(:user)
      team.add_player!(player)
      user.grant(:edit, team)

      sign_in user
      request.env['HTTP_REFERER'] = '/'
      patch :leave, params: { id: team.id, user_id: player.id }

      expect(team.on_roster?(player)).to be(false)
      expect(team.invited?(player)).to be(false)
    end
  end

  describe 'DELETE #destroy' do
    let(:team) { create(:team) }
    let(:user) { create(:user) }
    let(:invited) { create(:user) }

    before do
      team.add_player!(user)
      invited.grant(:edit, team)
      team.invite(invited)
    end

    it 'succeeds for authorized user' do
      user.grant(:edit, :teams)
      sign_in user

      delete :destroy, params: { id: team.id }

      expect(Team.all).to be_empty
    end

    it 'succeeds for authorized captains' do
      invited.grant(:edit, team)
      sign_in invited

      delete :destroy, params: { id: team.id }

      expect(Team.all).to be_empty
    end

    it 'fails for unauthorized user' do
      sign_in user

      delete :destroy, params: { id: team.id }

      expect(Team.where(id: team.id)).to exist
    end
  end
end
