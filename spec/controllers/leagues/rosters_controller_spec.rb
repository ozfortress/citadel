require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe Leagues::RostersController do
  let(:user) { create(:user) }
  let(:team) { create(:team) }
  let(:comp) { create(:competition, signuppable: true, min_players: 1) }
  let!(:div) { create(:division, competition: comp) }

  describe 'GET #new' do
    it 'succeeds for authorized user' do
      user.grant(:edit, team)
      sign_in user

      get :new, league_id: comp.id

      expect(response).to have_http_status(:success)
    end

    it 'succeeds for authorized user on team' do
      user.grant(:edit, team)
      sign_in user

      get :new, league_id: comp.id, team_id: team.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      user.grant(:edit, team)
      sign_in user

      post :create, league_id: comp.id, team_id: team.id,
                    competition_roster: { name: 'A', description: 'B',
                                          division_id: div.id, player_ids: [user.id, ''] }

      roster = CompetitionRoster.first
      expect(roster.name).to eq('A')
      expect(roster.description).to eq('B')
      expect(roster.team).to eq(team)
      expect(roster.player_users).to eq([user])
      expect(roster.division).to eq(div)
    end

    it 'fails for too little players' do
      user.grant(:edit, team)
      sign_in user

      post :create, league_id: comp.id, team_id: team.id,
                    competition_roster: { name: 'A', description: 'B',
                                          division_id: div.id, player_ids: [''] }

      expect(response).to render_template(:new)
    end
  end

  describe 'GET #show' do
    let(:roster) { create(:competition_roster, division: div) }

    it 'succeeds' do
      get :show, league_id: comp.id, id: roster.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    let(:roster) { create(:competition_roster, division: div, team: team) }

    it 'succeeds for authorized user' do
      user.grant(:edit, team)
      sign_in user

      get :edit, league_id: comp.id, id: roster.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let(:roster) { create(:competition_roster, division: div, team: team) }
    let(:div2) { create(:division, competition: comp) }

    it 'succeeds for authorized user' do
      user.grant(:edit, team)
      sign_in user

      patch :update, league_id: comp.id, id: roster.id,
                     competition_roster: { name: 'A', description: 'B', division_id: div2 }

      roster = CompetitionRoster.first
      expect(roster.name).to eq('A')
      expect(roster.description).to eq('B')
      expect(roster.division).to eq(div2)
    end
  end
end
