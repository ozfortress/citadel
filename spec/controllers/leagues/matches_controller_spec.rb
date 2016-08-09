require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe Leagues::MatchesController do
  let(:user) { create(:user) }
  let(:map) { create(:map) }
  let!(:league) { create(:league, matches_submittable: true) }
  let!(:div) { create(:league_division, league: league) }
  let!(:team1) { create(:league_roster, division: div) }
  let!(:team2) { create(:league_roster, division: div) }

  describe 'GET #index' do
    it 'succeeds for authorized user' do
      user.grant(:edit, league)
      sign_in user

      get :index, league_id: league.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'succeeds for authorized user' do
      user.grant(:edit, league)
      sign_in user

      get :new, league_id: league.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      user.grant(:edit, league)
      sign_in user

      post :create, league_id: league.id, division_id: div.id, match: {
        home_team_id: team1.id, away_team_id: team2.id, round: 3,
        rounds_attributes: [
          { map_id: map.id }
        ]
      }

      match = league.matches.first
      expect(match).to_not be nil
      expect(match.home_team).to eq(team1)
      expect(match.away_team).to eq(team2)
      expect(match.round).to eq(3)
      expect(match.rounds.count).to eq(1)
      round = match.rounds.first
      expect(round.map).to eq(map)
    end

    it 'fails with same team' do
      user.grant(:edit, league)
      sign_in user

      post :create, league_id: league.id, division_id: div.id, match: {
        home_team_id: team1.id, away_team_id: team1.id,
      }

      expect(response).to render_template(:new)
    end

    it 'fails with teams across divisions' do
      div2 = create(:league_division, league: league)
      team2.update!(division: div2)
      user.grant(:edit, league)
      sign_in user

      post :create, league_id: league.id, division_id: div2.id, match: {
        home_team_id: team1.id, away_team_id: team2.id,
        rounds_attributes: [
          { map_id: map.id }
        ]
      }

      expect(response).to render_template(:new)
    end

    it 'redirects for unauthorized user' do
      sign_in user

      post :create, league_id: league.id

      expect(response).to redirect_to(league_path(league.id))
    end

    it 'redirects for unauthenticated user' do
      post :create, league_id: league.id

      expect(response).to redirect_to(league_path(league.id))
    end
  end

  describe 'GET #generate' do
    it 'succeeds for authorized user' do
      user.grant(:edit, league)
      sign_in user

      get :generate, league_id: league.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create_round' do
    it 'succeeds for authorized user' do
      user.grant(:edit, league)
      sign_in user

      post :create_round, league_id: league.id, match: {
        generate_kind: :swiss, division_id: div.id, round: 3,
        rounds_attributes: [
          { map_id: map.id }
        ]
      }

      expect(league.matches.size).to eq(1)
      league.matches.each do |match|
        expect(match.round).to eq(3)
        expect(match.rounds.size).to eq(1)
        expect(match.rounds.first.map).to eq(map)
      end
    end

    it 'fails with invalid data' do
      user.grant(:edit, league)
      sign_in user

      post :create_round, league_id: league.id, match: {
        generate_kind: :swiss, division_id: div.id, round: -1
      }

      expect(league.matches).to be_empty
      expect(response).to render_template(:generate)
    end
  end

  describe 'GET #show' do
    let!(:match) { create(:league_match, home_team: team1, away_team: team2) }

    it 'succeeds' do
      get :show, league_id: league.id, id: match.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    let!(:match) { create(:league_match, home_team: team1, away_team: team2) }

    it 'succeeds for authorized user' do
      user.grant(:edit, league)
      sign_in user

      get :edit, league_id: league.id, id: match.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let!(:match) { create(:league_match, home_team: team1, away_team: team2) }
    let!(:team3) { create(:league_roster, division: div) }
    let!(:map2) { create(:map) }
    let!(:round) { create(:league_match_round, match: match) }

    it 'succeeds for authorized user' do
      user.grant(:edit, league)
      sign_in user

      patch :update, league_id: league.id, id: match.id, match: {
        home_team_id: team3.id, away_team_id: team2.id, round: 5,
        rounds_attributes: [
          { id: round.id, _destroy: true, map_id: map.id },
          { map_id: map2.id },
        ]
      }

      match.reload
      expect(match).to_not be(nil)
      expect(match.home_team).to eq(team3)
      expect(match.away_team).to eq(team2)
      expect(match.round).to eq(5)
      round = match.rounds.first
      expect(round.map).to eq(map2)
    end

    it 'fails with invalid data' do
      user.grant(:edit, league)
      sign_in user

      patch :update, league_id: league.id, id: match.id, match: {
        home_team_id: team1.id, away_team_id: team1.id
      }

      match.reload
      expect(match.away_team).to eq(team2)
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #comms' do
    let!(:match) { create(:league_match, home_team: team1, away_team: team2) }

    it 'succeeds for authorized user' do
      user.grant(:edit, team1.team)
      sign_in user

      post :comms, league_id: league.id, id: match.id, comm: { content: 'A' }

      comm = match.comms.first
      expect(comm).to_not be nil
      expect(comm.match).to eq(match)
      expect(comm.content).to eq('A')
    end

    it 'fails with invalid data' do
      user.grant(:edit, team1.team)
      sign_in user

      post :comms, league_id: league.id, id: match.id, comm: { content: nil }

      expect(match.comms.first).to be(nil)
      expect(response).to render_template(:show)
    end

    it 'fails for unauthorized user' do
      sign_in user

      post :comms, league_id: league.id, id: match.id, comm: { content: 'A' }

      expect(match.comms.first).to be(nil)
    end
  end

  describe 'PATCH #scores' do
    let!(:match) { create(:league_match, home_team: team1, away_team: team2) }
    let!(:round) { create(:league_match_round, match: match) }

    it 'succeeds for admin user' do
      user.grant(:edit, league)
      sign_in user

      patch :scores, league_id: league.id, id: match.id, match: {
        status: :confirmed, rounds_attributes: {
          id: round.id, home_team_score: 2, away_team_score: 5,
        }
      }

      match.reload
      expect(match.status).to eq('confirmed')
      expect(match.rounds.size).to eq(1)
      round.reload
      expect(round.home_team_score).to eq(2)
      expect(round.away_team_score).to eq(5)
    end

    it 'succeeds for admin user ff' do
      user.grant(:edit, league)
      sign_in user

      patch :scores, league_id: league.id, id: match.id, match: {
        forfeit_by: :home_team_forfeit,
      }

      match.reload
      expect(match.status).to eq('confirmed')
      expect(match.forfeit_by).to eq('home_team_forfeit')
    end

    it 'succeeds for home team authorized user' do
      user.grant(:edit, team1.team)
      sign_in user

      patch :scores, league_id: league.id, id: match.id, match: {
        rounds_attributes: {
          id: round.id, home_team_score: 2, away_team_score: 5,
        }
      }

      match.reload
      expect(match.status).to eq('submitted_by_home_team')
      expect(match.rounds.size).to eq(1)
      round.reload
      expect(round.home_team_score).to eq(2)
      expect(round.away_team_score).to eq(5)
    end

    it 'succeeds for away team authorized user' do
      user.grant(:edit, team2.team)
      sign_in user

      patch :scores, league_id: league.id, id: match.id, match: {
        rounds_attributes: {
          id: round.id, home_team_score: 2, away_team_score: 5,
        }
      }

      match.reload
      expect(match.status).to eq('submitted_by_away_team')
      expect(match.rounds.size).to eq(1)
      round.reload
      expect(round.home_team_score).to eq(2)
      expect(round.away_team_score).to eq(5)
    end

    it 'fails with invalid data' do
      user.grant(:edit, team1.team)
      sign_in user

      patch :scores, league_id: league.id, id: match.id, match: {
        rounds_attributes: {
          id: round.id, home_team_score: -1, away_team_score: 5,
        }
      }

      match.reload
      expect(match.status).to eq('pending')
      expect(response).to render_template(:show)
    end

    it "doesn't allow status changes for non-admins with invalid data" do
      user.grant(:edit, team1.team)
      sign_in user

      patch :scores, league_id: league.id, id: match.id, match: {
        status: :confirmed, rounds_attributes: {
          id: round.id, home_team_score: 2, away_team_score: 5,
        }
      }

      match.reload
      expect(match.status).to eq('submitted_by_home_team')
      expect(response).to redirect_to(league_match_path(league.id, match.id))
    end

    it "doesn't allow score submission overriding" do
      match.update(status: 'submitted_by_home_team')
      user.grant(:edit, team2.team)
      sign_in user

      patch :scores, league_id: league.id, id: match.id, match: {
        rounds_attributes: {
          id: round.id, home_team_score: 2, away_team_score: 5,
        }
      }

      match.reload
      expect(match.status).to eq('submitted_by_home_team')
      expect(response).to redirect_to(league_match_path(league.id, match.id))
    end
  end

  describe 'PATCH #confirm' do
    let!(:match) do
      create(:league_match, home_team: team1, away_team: team2,
                            status: :submitted_by_home_team)
    end
    let!(:round) { create(:league_match_round, match: match) }

    it 'succeeds for admin user' do
      user.grant(:edit, league)
      sign_in user

      patch :confirm, league_id: league.id, id: match.id, confirm: 'true'

      match.reload
      expect(match.status).to eq('confirmed')
    end

    it 'succeeds for away team authorized user' do
      user.grant(:edit, team2.team)
      sign_in user

      patch :confirm, league_id: league.id, id: match.id, confirm: 'true'

      match.reload
      expect(match.status).to eq('confirmed')
    end

    it 'fails for home team authorized user' do
      user.grant(:edit, team1.team)
      sign_in user

      patch :confirm, league_id: league.id, id: match.id, confirm: 'true'

      match.reload
      expect(match.status).to eq('submitted_by_home_team')
    end
  end

  describe 'PATCH #forfeit' do
    let!(:match) { create(:league_match, home_team: team1, away_team: team2) }
    let!(:round) { create(:league_match_round, match: match) }

    before do
      league.update!(allow_round_draws: false)
    end

    it 'succeeds for home team authorized user' do
      user.grant(:edit, team1.team)
      sign_in user

      patch :forfeit, league_id: league.id, id: match.id

      match.reload
      expect(match.status).to eq('confirmed')
      expect(match.forfeit_by).to eq('home_team_forfeit')
    end

    it 'succeeds for away team authorized user' do
      user.grant(:edit, team2.team)
      sign_in user

      patch :forfeit, league_id: league.id, id: match.id

      match.reload
      expect(match.status).to eq('confirmed')
      expect(match.forfeit_by).to eq('away_team_forfeit')
    end
  end

  describe 'DELETE #destroy' do
    let!(:match) { create(:league_match, home_team: team1, away_team: team2) }

    it 'succeeds for authorized user' do
      user.grant(:edit, league)
      sign_in user

      delete :destroy, league_id: league.id, id: match.id

      expect(League::Match.exists?(match.id)).to be(false)
    end

    it 'fails for team authorized user' do
      user.grant(:edit, team1.team)
      sign_in user

      delete :destroy, league_id: league.id, id: match.id

      expect(League::Match.exists?(match.id)).to be(true)
    end

    it 'fails for unauthorized user' do
      sign_in user

      delete :destroy, league_id: league.id, id: match.id

      expect(League::Match.exists?(match.id)).to be(true)
    end

    it 'fails for unauthenticated user' do
      delete :destroy, league_id: league.id, id: match.id

      expect(League::Match.exists?(match.id)).to be(true)
    end
  end
end
