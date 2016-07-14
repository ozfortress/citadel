require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe Leagues::RostersController do
  let(:user) { create(:user) }
  let(:team) { create(:team) }
  let(:comp) { create(:competition, signuppable: true, min_players: 1) }
  let!(:div) { create(:division, competition: comp) }
  let!(:div2) { create(:division, competition: comp) }

  before do
    team.add_player!(user)
  end

  describe 'GET #new' do
    it 'succeeds for authorized user' do
      user.grant(:edit, team)
      sign_in user

      get :new, league_id: comp.id

      expect(response).to have_http_status(:success)
    end

    it 'succeeds for authorized user with selected team' do
      user.grant(:edit, team)
      sign_in user

      get :new, league_id: comp.id, team_id: team.id

      expect(response).to have_http_status(:success)
    end

    it 'redirects for unauthorized user' do
      sign_in user

      get :new, league_id: comp.id

      expect(response).to redirect_to(league_path(comp.id))
    end

    it 'redirects for unauthenticated user' do
      get :new, league_id: comp.id

      expect(response).to redirect_to(league_path(comp.id))
    end
  end

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      user.grant(:edit, team)
      sign_in user

      post :create, league_id: comp.id, team_id: team.id,
                    competition_roster: { name: 'A', description: 'B',
                                          division_id: div2.id, player_ids: [user.id, ''] }

      roster = CompetitionRoster.first
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

      post :create, league_id: comp.id, team_id: team.id,
                    competition_roster: { name: 'A', description: 'B',
                                          division_id: div.id, player_ids: [''] }

      expect(response).to render_template(:new)
    end

    it 'redirects for unauthorized user for team' do
      team2 = create(:team)
      user.grant(:edit, team2)
      sign_in user

      post :create, league_id: comp.id, team_id: team.id

      expect(response).to redirect_to(league_path(comp.id))
    end

    it 'redirects for unauthorized user' do
      sign_in user

      post :create, league_id: comp.id, team_id: team.id

      expect(response).to redirect_to(league_path(comp.id))
    end

    it 'redirects for unauthenticated user' do
      post :create, league_id: comp.id, team_id: team.id

      expect(response).to redirect_to(league_path(comp.id))
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

    it 'succeeds for authorized captain' do
      user.grant(:edit, roster.team)
      sign_in user

      get :edit, league_id: comp.id, id: roster.id

      expect(response).to have_http_status(:success)
    end

    it 'succeeds for authorized admin' do
      user.grant(:edit, comp)
      sign_in user

      get :edit, league_id: comp.id, id: roster.id

      expect(response).to have_http_status(:success)
    end

    it 'redirects for authorized captain if team disbanded' do
      user.grant(:edit, roster.team)
      comp.update!(signuppable: false)
      roster.disband
      sign_in user

      get :edit, league_id: comp.id, id: roster.id

      expect(response).to redirect_to(league_roster_path(comp, roster))
    end
  end

  describe 'PATCH #update' do
    let(:roster) { create(:competition_roster, name: 'B', division: div, team: team) }

    it 'succeeds for authorized admin' do
      user.grant(:edit, comp)
      sign_in user

      patch :update, league_id: comp.id, id: roster.id,
                     competition_roster: { name: 'A', description: 'B', division_id: div2 }

      roster.reload
      expect(roster.name).to eq('A')
      expect(roster.description).to eq('B')
      expect(roster.division).to eq(div2)
    end

    it 'succeeds for authorized captain' do
      user.grant(:edit, roster.team)
      sign_in user

      patch :update, league_id: comp.id, id: roster.id,
                     competition_roster: { description: 'B' }

      roster.reload
      expect(roster.name).to eq('B')
      expect(roster.description).to eq('B')
      expect(roster.division).to eq(div)
    end

    it 'redirects for authorized captain if team disbanded' do
      user.grant(:edit, roster.team)
      comp.update!(signuppable: false)
      roster.disband
      sign_in user

      patch :update, league_id: comp.id, id: roster.id,
                     competition_roster: { description: 'B' }

      roster.reload
      expect(roster.name).to eq('B')
      expect(roster.description).to_not eq('B')
      expect(roster.division).to eq(div)
    end

    it 'fails with invalid data' do
      user.grant(:edit, comp)
      sign_in user

      patch :update, league_id: comp.id, id: roster.id,
                     competition_roster: { name: '', description: 'B', division_id: div2 }

      roster.reload
      expect(roster.name).not_to eq('')
      expect(response).to render_template(:edit)
    end

    it 'redirects for unauthorized user' do
      sign_in user

      patch :update, league_id: comp.id, id: roster.id

      expect(response).to redirect_to(league_roster_path(comp.id, roster))
    end

    it 'redirects for unauthenticated user' do
      patch :update, league_id: comp.id, id: roster.id

      expect(response).to redirect_to(league_roster_path(comp.id, roster))
    end
  end

  describe 'GET #review' do
    let(:roster) { create(:competition_roster, division: div, team: team, approved: false) }

    it 'succeeds for authorized user' do
      user.grant(:edit, comp)
      sign_in user

      get :review, league_id: comp.id, id: roster.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #approve' do
    let(:roster) { create(:competition_roster, division: div, team: team, approved: false) }

    it 'succeeds for authorized user' do
      user.grant(:edit, comp)
      sign_in user

      patch :approve, league_id: comp.id, id: roster.id,
                      competition_roster: { name: 'A', division_id: div2.id }

      roster.reload
      expect(roster.name).to eq('A')
      expect(roster.division).to eq(div2)
    end

    it 'fails with invalid name' do
      user.grant(:edit, comp)
      sign_in user

      patch :approve, league_id: comp.id, id: roster.id,
                      competition_roster: { name: '', division_id: div2.id }

      roster.reload
      expect(roster.name).to_not eq('')
      expect(response).to render_template(:review)
    end

    it 'redirects for unauthorized user' do
      sign_in user

      patch :approve, league_id: comp.id, id: roster.id

      expect(response).to redirect_to(league_path(comp.id))
    end

    it 'redirects for unauthenticated user' do
      patch :approve, league_id: comp.id, id: roster.id

      expect(response).to redirect_to(league_path(comp.id))
    end
  end

  describe 'DELETE #destroy' do
    let(:roster) { create(:competition_roster, division: div, team: team, approved: false) }

    it 'succeeds for authorized admin' do
      user.grant(:edit, comp)
      sign_in user

      delete :destroy, league_id: comp.id, id: roster.id

      expect(CompetitionRoster.exists?(roster.id)).to be(false)
    end

    it 'succeeds for authorized team captain' do
      user.grant(:edit, team)
      sign_in user

      delete :destroy, league_id: comp.id, id: roster.id

      expect(CompetitionRoster.exists?(roster.id)).to be(false)
    end

    it 'disbands roster for authorized team captain if not signuppable and allowed' do
      user.grant(:edit, team)
      comp.update!(signuppable: false, allow_disbanding: true)
      sign_in user

      delete :destroy, league_id: comp.id, id: roster.id

      expect(CompetitionRoster.exists?(roster.id)).to be(true)
      expect(roster.reload.disbanded?).to be(true)
    end

    it 'fails disbanding roster for authorized team captain when not allowed' do
      user.grant(:edit, team)
      comp.update!(signuppable: false)
      sign_in user

      delete :destroy, league_id: comp.id, id: roster.id

      expect(CompetitionRoster.exists?(roster.id)).to be(true)
      expect(roster.reload.disbanded?).to be(false)
    end

    it 'redirects for unauthorized user' do
      sign_in user

      delete :destroy, league_id: comp.id, id: roster.id

      expect(CompetitionRoster.exists?(roster.id)).to be(true)
      expect(response)
    end

    it 'redirects for unauthenticated user' do
      delete :destroy, league_id: comp.id, id: roster.id

      expect(CompetitionRoster.exists?(roster.id)).to be(true)
    end
  end
end
