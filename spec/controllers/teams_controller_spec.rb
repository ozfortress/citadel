require 'rails_helper'
require 'support/factory_girl'
require 'support/devise'

describe TeamsController do
  let(:user) { create(:user) }
  let(:format) { create(:format) }

  describe 'GET #index' do
    it 'returns http success' do
      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      sign_in user

      get :new

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'creates a team' do
      sign_in user
      post :create, team: { format_id: format.id, name: 'A', description: 'B' }

      team = Team.find_by(name: 'A')
      expect(team).to_not be_nil
      expect(team.format).to eq(format)
      expect(team.description).to eq('B')
      expect(team.on_roster?(user)).to be(true)
      expect(user.can?(:edit, team)).to be(true)
    end

    it 'handles duplicate teams' do
      create(:team, name: 'A', format: format)

      sign_in user
      post :create, team: { format_id: format.id, name: 'A', description: 'B' }

      expect(response).to render_template(:new)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      team = create(:team, format: format)

      get :show, id: team.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      team = create(:team, format: format)
      user.grant(:edit, team)

      sign_in user
      get :edit, id: team.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    it 'updates a team' do
      team = create(:team, name: 'A', description: 'B', format: format)
      user.grant(:edit, team)

      sign_in user
      patch :update, id: team.id, team: { name: 'C', description: 'D' }

      team = Team.find(team.id)
      expect(team.name).to eq('C')
      expect(team.description).to eq('D')
    end
  end

  describe 'GET #recruit' do
    it 'returns http success' do
      team = create(:team, format: format)
      user.grant(:edit, team)

      sign_in user
      get :recruit, id: team.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #invite' do
    it 'invites a player to a team' do
      team = create(:team, format: format)
      invited = create(:user, name: 'A', steam_id: 3)
      user.grant(:edit, team)

      sign_in user
      patch :invite, id: team.id, user_id: invited.id

      invite = invited.team_invites.first
      expect(invite).to_not be_nil
      expect(invite.user).to eq(invited)
      expect(invite.team).to eq(team)
      expect(team.invited?(invited)).to be(true)
    end
  end

  describe 'PATCH #leave' do
    it 'removes a player from a team' do
      team = create(:team, format: format)
      team.add_player(user)

      sign_in user
      request.env['HTTP_REFERER'] = '/'
      patch :leave, id: team.id

      expect(team.on_roster?(user)).to be(false)
      expect(team.invited?(user)).to be(false)
    end

    it 'kicks a player from a team' do
      team = create(:team, format: format)
      player = create(:user, name: 'A', steam_id: 3)
      team.add_player(player)
      user.grant(:edit, team)

      sign_in user
      request.env['HTTP_REFERER'] = '/'
      patch :leave, id: team.id, user_id: player.id

      expect(team.on_roster?(player)).to be(false)
      expect(team.invited?(player)).to be(false)
    end
  end

  describe 'PATCH #grant' do
    it 'grants team permission from admin' do
      team = create(:team, format: format)
      admin = create(:user, name: 'A', steam_id: 3)
      admin.grant(:edit, :teams)

      sign_in admin
      request.env['HTTP_REFERER'] = '/'
      patch :grant, id: team.id, user_id: user.id

      expect(user.can?(:edit, team)).to be(true)
      expect(user.can?(:edit, :teams)).to be(false)
    end
  end

  describe 'PATCH #revoke' do
    it 'returns http success' do
      team = create(:team, format: format)
      admin = create(:user, name: 'A', steam_id: 3)
      admin.grant(:edit, :teams)
      user.grant(:edit, team)

      sign_in admin
      request.env['HTTP_REFERER'] = '/'
      patch :revoke, id: team.id, user_id: user.id

      expect(user.can?(:edit, team)).to be(false)
      expect(user.can?(:edit, :teams)).to be(false)
    end
  end
end
