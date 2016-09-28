require 'rails_helper'

describe Leagues::RostersController do
  let(:user) { create(:user) }
  let(:team) { create(:team) }
  let(:league) { create(:league, signuppable: true, min_players: 1) }
  let!(:div) { create(:league_division, league: league) }
  let!(:div2) { create(:league_division, league: league) }

  before do
    team.add_player!(user)
  end

  describe 'GET #new' do
    it 'succeeds for authorized user' do
      user.grant(:edit, team)
      sign_in user

      get :new, params: { league_id: league.id }

      expect(response).to have_http_status(:success)
    end

    it 'succeeds for authorized user with selected team' do
      user.grant(:edit, team)
      sign_in user

      get :new, params: { league_id: league.id, team_id: team.id }

      expect(response).to have_http_status(:success)
    end

    it 'redirects for unauthorized user' do
      sign_in user

      get :new, params: { league_id: league.id }

      expect(response).to redirect_to(league_path(league.id))
    end

    it 'redirects for unauthenticated user' do
      get :new, params: { league_id: league.id }

      expect(response).to redirect_to(league_path(league.id))
    end
  end

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      user.grant(:edit, team)
      sign_in user

      post :create, params: {
        league_id: league.id, team_id: team.id,
        roster: { name: 'A', description: 'B',
                  division_id: div2.id, player_ids: [user.id, ''] }
      }

      roster = League::Roster.first
      expect(roster).to_not be(nil)
      expect(roster.name).to eq('A')
      expect(roster.description).to eq('B')
      expect(roster.team).to eq(team)
      expect(roster.player_users).to eq([user])
      expect(roster.division).to eq(div2)
    end

    it 'fails for too little players' do
      user.grant(:edit, team)
      sign_in user

      post :create, params: {
        league_id: league.id, team_id: team.id,
        roster: { name: 'A', description: 'B',
                  division_id: div.id, player_ids: [''] }
      }
    end

    it 'redirects for unauthorized user for team' do
      team2 = create(:team)
      user.grant(:edit, team2)
      sign_in user

      post :create, params: { league_id: league.id, team_id: team.id }

      expect(response).to redirect_to(league_path(league.id))
    end

    it 'redirects for unauthorized user' do
      sign_in user

      post :create, params: { league_id: league.id, team_id: team.id }

      expect(response).to redirect_to(league_path(league.id))
    end

    it 'redirects for unauthenticated user' do
      post :create, params: { league_id: league.id, team_id: team.id }

      expect(response).to redirect_to(league_path(league.id))
    end
  end

  describe 'GET #show' do
    let(:roster) { create(:league_roster, division: div) }

    it 'succeeds' do
      get :show, params: { league_id: league.id, id: roster.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    let(:roster) { create(:league_roster, division: div, team: team) }

    it 'succeeds for authorized captain' do
      user.grant(:edit, roster.team)
      sign_in user

      get :edit, params: { league_id: league.id, id: roster.id }

      expect(response).to have_http_status(:success)
    end

    it 'succeeds for authorized admin' do
      user.grant(:edit, league)
      sign_in user

      get :edit, params: { league_id: league.id, id: roster.id }

      expect(response).to have_http_status(:success)
    end

    it 'redirects for authorized captain if team disbanded' do
      user.grant(:edit, roster.team)
      league.update!(signuppable: false)
      roster.disband
      sign_in user

      get :edit, params: { league_id: league.id, id: roster.id }

      expect(response).to redirect_to(league_roster_path(league, roster))
    end
  end

  describe 'PATCH #update' do
    let(:roster) { create(:league_roster, name: 'B', division: div, team: team) }

    it 'succeeds for authorized admin' do
      user.grant(:edit, league)
      sign_in user

      patch :update, params: {
        league_id: league.id, id: roster.id,
        roster: { name: 'A', description: 'B', division_id: div2, seeding: 2 }
      }

      roster.reload
      expect(roster.name).to eq('A')
      expect(roster.description).to eq('B')
      expect(roster.division).to eq(div2)
      expect(roster.seeding).to eq(2)
    end

    it 'succeeds for authorized captain' do
      user.grant(:edit, roster.team)
      sign_in user

      patch :update, params: {
        league_id: league.id, id: roster.id, roster: { description: 'B' }
      }

      roster.reload
      expect(roster.name).to eq('B')
      expect(roster.description).to eq('B')
      expect(roster.division).to eq(div)
    end

    it 'succeeds for authorized captain with locked schedule' do
      user.grant(:edit, roster.team)
      league.update!(schedule: :weeklies, schedule_locked: true,
                     weekly_scheduler: build(:league_schedulers_weekly))
      roster.schedule_data = league.scheduler.default_schedule
      roster.save!
      sign_in user

      patch :update, params: {
        league_id: league.id, id: roster.id, roster: {
          description: 'B', schedule_data: { foo: 'bar' } },
      }

      roster.reload
      expect(roster.name).to eq('B')
      expect(roster.description).to eq('B')
      expect(roster.division).to eq(div)
    end

    it 'redirects for authorized captain if team disbanded' do
      user.grant(:edit, roster.team)
      league.update!(signuppable: false)
      roster.disband
      sign_in user

      patch :update, params: {
        league_id: league.id, id: roster.id, roster: { description: 'B' }
      }

      roster.reload
      expect(roster.name).to eq('B')
      expect(roster.description).to_not eq('B')
      expect(roster.division).to eq(div)
    end

    it 'fails with invalid data' do
      user.grant(:edit, league)
      sign_in user

      patch :update, params: {
        league_id: league.id, id: roster.id,
        roster: { name: '', description: 'B', division_id: div2 }
      }

      roster.reload
      expect(roster.name).not_to eq('')
    end

    it 'redirects for unauthorized user' do
      sign_in user

      patch :update, params: { league_id: league.id, id: roster.id }

      expect(response).to redirect_to(league_roster_path(league.id, roster))
    end

    it 'redirects for unauthenticated user' do
      patch :update, params: { league_id: league.id, id: roster.id }

      expect(response).to redirect_to(league_roster_path(league.id, roster))
    end
  end

  describe 'GET #review' do
    let(:roster) { create(:league_roster, division: div, team: team, approved: false) }

    it 'succeeds for authorized user' do
      user.grant(:edit, league)
      sign_in user

      get :review, params: { league_id: league.id, id: roster.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #approve' do
    let(:roster) { create(:league_roster, division: div, team: team, approved: false) }

    it 'succeeds for authorized user' do
      user.grant(:edit, league)
      sign_in user

      patch :approve, params: {
        league_id: league.id, id: roster.id,
        roster: { name: 'A', division_id: div2.id, seeding: 2 }
      }

      roster.reload
      expect(roster.name).to eq('A')
      expect(roster.division).to eq(div2)
      expect(roster.seeding).to eq(2)
    end

    it 'fails with invalid name' do
      user.grant(:edit, league)
      sign_in user

      patch :approve, params: {
        league_id: league.id, id: roster.id,
        roster: { name: '', division_id: div2.id }
      }

      roster.reload
      expect(roster.name).to_not eq('')
    end

    it 'redirects for unauthorized user' do
      sign_in user

      patch :approve, params: { league_id: league.id, id: roster.id }

      expect(response).to redirect_to(league_path(league.id))
    end

    it 'redirects for unauthenticated user' do
      patch :approve, params: { league_id: league.id, id: roster.id }

      expect(response).to redirect_to(league_path(league.id))
    end
  end

  describe 'DELETE #destroy' do
    let(:roster) { create(:league_roster, division: div, team: team, approved: false) }

    it 'succeeds for authorized admin' do
      user.grant(:edit, league)
      sign_in user

      delete :destroy, params: { league_id: league.id, id: roster.id }

      expect(League::Roster.exists?(roster.id)).to be(false)
    end

    it 'succeeds for authorized team captain' do
      user.grant(:edit, team)
      sign_in user

      delete :destroy, params: { league_id: league.id, id: roster.id }

      expect(League::Roster.exists?(roster.id)).to be(false)
    end

    it 'disbands roster for authorized team captain if not signuppable and allowed' do
      user.grant(:edit, team)
      league.update!(signuppable: false, allow_disbanding: true)
      sign_in user

      delete :destroy, params: { league_id: league.id, id: roster.id }

      expect(League::Roster.exists?(roster.id)).to be(true)
      expect(roster.reload.disbanded?).to be(true)
    end

    it 'fails disbanding roster for authorized team captain when not allowed' do
      user.grant(:edit, team)
      league.update!(signuppable: false)
      sign_in user

      delete :destroy, params: { league_id: league.id, id: roster.id }

      expect(League::Roster.exists?(roster.id)).to be(true)
      expect(roster.reload.disbanded?).to be(false)
    end

    it 'redirects for unauthorized user' do
      sign_in user

      delete :destroy, params: { league_id: league.id, id: roster.id }

      expect(League::Roster.exists?(roster.id)).to be(true)
      expect(response)
    end

    it 'redirects for unauthenticated user' do
      delete :destroy, params: { league_id: league.id, id: roster.id }

      expect(League::Roster.exists?(roster.id)).to be(true)
    end
  end
end
