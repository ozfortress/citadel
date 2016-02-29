require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe Leagues::MatchesController do
  let(:user) { create(:user) }
  let(:map) { create(:map) }
  let!(:comp) { create(:competition) }
  let!(:div) { create(:division, competition: comp) }
  let!(:team1) { create(:competition_roster, division: div) }
  let!(:team2) { create(:competition_roster, division: div) }

  describe 'GET #index' do
    it 'succeeds for authorized user' do
      user.grant(:edit, comp)
      sign_in user

      get :index, league_id: comp.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'succeeds for authorized user' do
      user.grant(:edit, comp)
      sign_in user

      get :new, league_id: comp.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      user.grant(:edit, comp)
      sign_in user

      post :create, league_id: comp.id, competition_match: {
        home_team_id: team1.id, away_team_id: team2.id,
        sets_attributes: [
          { map_id: map.id }
        ]
      }

      match = comp.matches.first
      expect(match).to_not be nil
      expect(match.home_team).to eq(team1)
      expect(match.away_team).to eq(team2)
      expect(match.sets.count).to eq(1)
      set = match.sets.first
      expect(set.map).to eq(map)
    end
  end

  describe 'GET #show' do
    let!(:match) { create(:competition_match, home_team: team1, away_team: team2) }

    it 'succeeds' do
      get :show, league_id: comp.id, id: match.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    let!(:match) { create(:competition_match, home_team: team1, away_team: team2) }

    it 'succeeds for authorized user' do
      user.grant(:edit, comp)
      sign_in user

      get :edit, league_id: comp.id, id: match.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let!(:match) { create(:competition_match, home_team: team1, away_team: team2) }
    let!(:team3) { create(:competition_roster, division: div) }
    let!(:map2) { create(:map) }
    let!(:set) { create(:competition_set, match: match) }

    it 'succeeds for authorized user' do
      user.grant(:edit, comp)
      sign_in user

      patch :update, league_id: comp.id, id: match.id, competition_match: {
        home_team_id: team3.id, away_team_id: team2.id,
        sets_attributes: [
          { id: set.id, _destroy: true, map_id: map.id },
          { map_id: map2.id },
        ]
      }

      match = comp.matches.first
      expect(match).to_not be nil
      expect(match.home_team).to eq(team3)
      expect(match.away_team).to eq(team2)
      expect(match.sets.length).to eq(1)
      set = match.sets.first
      expect(set.map).to eq(map2)
    end
  end

  describe 'PATCH #comms' do
    let!(:match) { create(:competition_match, home_team: team1, away_team: team2) }

    it 'succeeds for authorized user' do
      user.grant(:edit, team1.team)
      sign_in user

      patch :comms, league_id: comp.id, id: match.id, competition_comm: { content: 'A' }

      comm = CompetitionComm.first
      expect(comm).to_not be nil
      expect(comm.match).to eq(match)
      expect(comm.content).to eq('A')
    end
  end
end
