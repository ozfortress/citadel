require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe Leagues::MatchesController do
  let(:user) { create(:user) }
  let(:map) { create(:map) }
  let!(:comp) { create(:competition, matches_submittable: true) }
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

    it 'fails with same team' do
      user.grant(:edit, comp)
      sign_in user

      post :create, league_id: comp.id, competition_match: {
        home_team_id: team1.id, away_team_id: team1.id
      }

      expect(response).to render_template(:new)
    end

    it 'fails with teams across divisions' do
      div2 = create(:division, competition: comp)
      team2.update!(division: div2)
      user.grant(:edit, comp)
      sign_in user

      post :create, league_id: comp.id, competition_match: {
        home_team_id: team1.id, away_team_id: team2.id,
        sets_attributes: [
          { map_id: map.id }
        ]
      }

      expect(response).to render_template(:new)
    end

    it 'redirects for unauthorized user' do
      sign_in user

      post :create, league_id: comp.id

      expect(response).to redirect_to(league_path(comp.id))
    end

    it 'redirects for unauthenticated user' do
      post :create, league_id: comp.id

      expect(response).to redirect_to(league_path(comp.id))
    end
  end

  describe 'GET #generate' do
    it 'succeeds for authorized user' do
      user.grant(:edit, comp)
      sign_in user

      get :generate, league_id: comp.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create_round' do
    it 'succeeds for authorized user' do
      user.grant(:edit, comp)
      sign_in user

      post :create_round, league_id: comp.id, competition_match: {
        generate_kind: :swiss,
        division_id: div.id,
        sets_attributes: [
          { map_id: map.id }
        ]
      }

      expect(comp.matches.size).to eq(1)
      expect(comp.matches.first.sets.first.map).to eq(map)
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

      match.reload
      expect(match).to_not be(nil)
      expect(match.home_team).to eq(team3)
      expect(match.away_team).to eq(team2)
      set = match.sets.first
      expect(set.map).to eq(map2)
    end

    it 'fails with invalid data' do
      user.grant(:edit, comp)
      sign_in user

      patch :update, league_id: comp.id, id: match.id, competition_match: {
        home_team_id: team1.id, away_team_id: team1.id
      }

      match.reload
      expect(match.away_team).to eq(team2)
      expect(response).to render_template(:edit)
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

    it 'fails with invalid data' do
      user.grant(:edit, team1.team)
      sign_in user

      patch :comms, league_id: comp.id, id: match.id, competition_comm: { content: nil }

      expect(CompetitionComm.first).to be(nil)
      expect(response).to render_template(:show)
    end
  end

  describe 'PATCH #scores' do
    let!(:match) { create(:competition_match, home_team: team1, away_team: team2) }
    let!(:set) { create(:competition_set, match: match) }

    it 'succeeds for admin user' do
      user.grant(:edit, comp)
      sign_in user

      patch :scores, league_id: comp.id, id: match.id, competition_match: {
        status: :confirmed, sets_attributes: {
          id: set.id, home_team_score: 2, away_team_score: 5,
        }
      }

      match.reload
      expect(match.status).to eq('confirmed')
      expect(match.sets.size).to eq(1)
      set.reload
      expect(set.home_team_score).to eq(2)
      expect(set.away_team_score).to eq(5)
    end

    it 'succeeds for admin user ff' do
      user.grant(:edit, comp)
      sign_in user

      patch :scores, league_id: comp.id, id: match.id, competition_match: {
        forfeit_by: :home_team_forfeit,
      }

      match.reload
      expect(match.status).to eq('confirmed')
      expect(match.forfeit_by).to eq('home_team_forfeit')
    end

    it 'succeeds for home team authorized user' do
      user.grant(:edit, team1.team)
      sign_in user

      patch :scores, league_id: comp.id, id: match.id, competition_match: {
        sets_attributes: {
          id: set.id, home_team_score: 2, away_team_score: 5,
        }
      }

      match.reload
      expect(match.status).to eq('submitted_by_home_team')
      expect(match.sets.size).to eq(1)
      set.reload
      expect(set.home_team_score).to eq(2)
      expect(set.away_team_score).to eq(5)
    end

    it 'succeeds for away team authorized user' do
      user.grant(:edit, team2.team)
      sign_in user

      patch :scores, league_id: comp.id, id: match.id, competition_match: {
        sets_attributes: {
          id: set.id, home_team_score: 2, away_team_score: 5,
        }
      }

      match.reload
      expect(match.status).to eq('submitted_by_away_team')
      expect(match.sets.size).to eq(1)
      set.reload
      expect(set.home_team_score).to eq(2)
      expect(set.away_team_score).to eq(5)
    end

    it 'fails with invalid data' do
      user.grant(:edit, team1.team)
      sign_in user

      patch :scores, league_id: comp.id, id: match.id, competition_match: {
        sets_attributes: {
          id: set.id, home_team_score: -1, away_team_score: 5,
        }
      }

      match.reload
      expect(match.status).to eq('pending')
      expect(response).to render_template(:show)
    end

    it "doesn't allow status changes for non-admins with invalid data" do
      user.grant(:edit, team1.team)
      sign_in user

      patch :scores, league_id: comp.id, id: match.id, competition_match: {
        status: :confirmed, sets_attributes: {
          id: set.id, home_team_score: 2, away_team_score: 5,
        }
      }

      match.reload
      expect(match.status).to eq('submitted_by_home_team')
      expect(response).to redirect_to(league_match_path(comp.id, match.id))
    end

    it "doesn't allow score submission overriding" do
      match.update(status: 'submitted_by_home_team')
      user.grant(:edit, team2.team)
      sign_in user

      patch :scores, league_id: comp.id, id: match.id, competition_match: {
        sets_attributes: {
          id: set.id, home_team_score: 2, away_team_score: 5,
        }
      }

      match.reload
      expect(match.status).to eq('submitted_by_home_team')
      expect(response).to redirect_to(league_match_path(comp.id, match.id))
    end
  end

  describe 'PATCH #confirm' do
    let!(:match) do
      create(:competition_match, home_team: team1, away_team: team2,
                                 status: :submitted_by_home_team)
    end
    let!(:set) { create(:competition_set, match: match) }

    it 'succeeds for admin user' do
      user.grant(:edit, comp)
      sign_in user

      patch :confirm, league_id: comp.id, id: match.id, confirm: 'true'

      match.reload
      expect(match.status).to eq('confirmed')
    end

    it 'succeeds for away team authorized user' do
      user.grant(:edit, team2.team)
      sign_in user

      patch :confirm, league_id: comp.id, id: match.id, confirm: 'true'

      match.reload
      expect(match.status).to eq('confirmed')
    end

    it 'fails for home team authorized user' do
      user.grant(:edit, team1.team)
      sign_in user

      patch :confirm, league_id: comp.id, id: match.id, confirm: 'true'

      match.reload
      expect(match.status).to eq('submitted_by_home_team')
    end
  end

  describe 'PATCH #forfeit' do
    let!(:match) { create(:competition_match, home_team: team1, away_team: team2) }
    let!(:set) { create(:competition_set, match: match) }

    it 'succeeds for home team authorized user' do
      user.grant(:edit, team1.team)
      sign_in user

      patch :forfeit, league_id: comp.id, id: match.id

      match.reload
      expect(match.status).to eq('confirmed')
      expect(match.forfeit_by).to eq('home_team_forfeit')
    end

    it 'succeeds for away team authorized user' do
      user.grant(:edit, team2.team)
      sign_in user

      patch :forfeit, league_id: comp.id, id: match.id

      match.reload
      expect(match.status).to eq('confirmed')
      expect(match.forfeit_by).to eq('away_team_forfeit')
    end
  end

  describe 'DELETE #destroy' do
    let!(:match) { create(:competition_match, home_team: team1, away_team: team2) }

    it 'succeeds for authorized user' do
      user.grant(:edit, comp)
      sign_in user

      delete :destroy, league_id: comp.id, id: match.id

      expect(CompetitionMatch.exists?(match.id)).to be(false)
    end

    it 'fails for team authorized user' do
      user.grant(:edit, team1.team)
      sign_in user

      delete :destroy, league_id: comp.id, id: match.id

      expect(CompetitionMatch.exists?(match.id)).to be(true)
    end

    it 'fails for unauthorized user' do
      sign_in user

      delete :destroy, league_id: comp.id, id: match.id

      expect(CompetitionMatch.exists?(match.id)).to be(true)
    end

    it 'fails for unauthenticated user' do
      delete :destroy, league_id: comp.id, id: match.id

      expect(CompetitionMatch.exists?(match.id)).to be(true)
    end
  end
end
