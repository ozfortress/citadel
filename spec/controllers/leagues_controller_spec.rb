require 'rails_helper'

describe LeaguesController do
  let(:admin) { create(:user) }

  before do
    admin.grant(:edit, :leagues)
  end

  describe 'GET #index' do
    before do
      create_list(:league, 50)
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
    it 'succeeds for authorized user' do
      sign_in admin

      get :new

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:format) { create(:format) }

    it 'succeeds for authorized user' do
      sign_in admin

      post :create, params: {
        league: { name: 'A', description: 'B', format_id: format.id, signuppable: true,
                  roster_locked: false, matches_submittable: true,
                  transfers_require_approval: false, allow_round_draws: true,
                  allow_disbanding: true, min_players: 1, max_players: 3,
                  points_per_round_won: 3, points_per_round_drawn: 2,
                  points_per_round_lost: 1, points_per_match_forfeit_loss: 5,
                  points_per_match_forfeit_win: 6, schedule: 'weeklies',
                  divisions_attributes: [{ name: 'PREM' }],
                  tiebreakers_attributes: [{ kind: 'round_wins' },
                                           { kind: 'round_score_difference' }],
                  weekly_scheduler_attributes: {
                    start_of_week: 'Monday', minimum_selected: 2,
                    days_indecies: [0, 1, 3, 5, 6] } }
      }

      comp = League.first
      expect(comp.name).to eq('A')
      expect(comp.description).to eq('B')
      expect(comp.format).to eq(format)
      expect(comp.signuppable).to be(true)
      expect(comp.roster_locked).to be(false)
      expect(comp.matches_submittable).to be(true)
      expect(comp.transfers_require_approval).to be(false)
      expect(comp.allow_round_draws).to be(true)
      expect(comp.allow_disbanding).to be(true)
      expect(comp.min_players).to eq(1)
      expect(comp.max_players).to eq(3)
      expect(comp.points_per_round_won).to eq(3)
      expect(comp.points_per_round_drawn).to eq(2)
      expect(comp.points_per_round_lost).to eq(1)
      expect(comp.points_per_match_forfeit_loss).to eq(5)
      expect(comp.points_per_match_forfeit_win).to eq(6)
      expect(comp.divisions.size).to eq(1)
      div = comp.divisions.first
      expect(div.name).to eq('PREM')
      expect(comp.tiebreakers.size).to eq(2)
      tieb1 = comp.tiebreakers.first
      expect(tieb1.kind).to eq('round_wins')
      tieb2 = comp.tiebreakers.last
      expect(tieb2.kind).to eq('round_score_difference')
      expect(comp.schedule).to eq('weeklies')
      scheduler = comp.weekly_scheduler
      expect(scheduler.start_of_week).to eq('Monday')
      expect(scheduler.minimum_selected).to eq(2)
      expect(scheduler.days).to eq([true, true, false, true, false, true, true])
    end

    it 'fails for invalid data' do
      sign_in admin

      post :create, params: {
        league: { name: 'A', description: 'B', format_id: format.id, signuppable: true,
                  roster_locked: false, matches_submittable: true, min_players: 5,
                  max_players: 3, divisions_attributes: [{ name: 'PREM' }] }
      }

      expect(League.first).to be(nil)
    end

    it 'redirects for unauthorized user' do
      sign_in create(:user)

      post :create

      expect(response).to redirect_to(leagues_path)
    end
  end

  describe 'GET #show' do
    let!(:comp) { create(:league, status: :running) }

    it 'succeeds for authorized user' do
      get :show, params: { id: comp.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    let(:comp) { create(:league) }

    it 'succeeds for authorized user' do
      sign_in admin

      get :edit, params: { id: comp.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let(:format) { create(:format) }
    let(:format2) { create(:format) }
    let(:comp) { create(:league, format: format) }

    it 'succeeds for authorized user' do
      sign_in admin

      patch :update, params: {
        id: comp.id, league: {
          name: 'A', description: 'B', format_id: format2.id, signuppable: true,
          roster_locked: false, matches_submittable: true, transfers_require_approval: false,
          min_players: 1, max_players: 3, divisions_attributes: [{ name: 'PREM' }]
        }
      }

      comp.reload
      expect(comp.name).to eq('A')
      expect(comp.description).to eq('B')
      expect(comp.format).to eq(format2)
      expect(comp.signuppable).to be(true)
      expect(comp.roster_locked).to be(false)
      expect(comp.matches_submittable).to be(true)
      expect(comp.transfers_require_approval).to be(false)
      expect(comp.min_players).to eq(1)
      expect(comp.max_players).to eq(3)
      expect(comp.divisions.size).to eq(1)
      div = comp.divisions.first
      expect(div.name).to eq('PREM')
    end

    it 'fails for authorized user' do
      sign_in admin

      patch :update, params: {
        id: comp.id, league: {
          name: '', description: 'B', format_id: format.id, signuppable: true,
          roster_locked: false, matches_submittable: true, min_players: 5, max_players: 3,
          divisions_attributes: [{ name: 'PREM' }]
        }
      }

      comp.reload
      expect(comp.name).not_to eq('')
    end

    it 'redirects for unauthorized user' do
      sign_in create(:user)

      patch :update, params: { id: comp.id }

      expect(response).to redirect_to(league_path(comp))
    end
  end

  describe 'PATCH #modify' do
    let(:comp) { create(:league, status: :hidden) }

    it 'succeeds for authorized user' do
      sign_in admin

      patch :modify, params: { id: comp.id, status: 'running' }

      comp.reload
      expect(comp.status).to eq('running')
    end
  end

  describe 'DELETE #destroy' do
    let(:comp) { create(:league) }

    it 'succeeds for hidden league' do
      sign_in admin

      delete :destroy, params: { id: comp.id }

      expect(League.count).to eq(0)
    end

    it 'fails for public league' do
      comp.status = 'running'
      comp.save!
      sign_in admin

      delete :destroy, params: { id: comp.id }

      expect(League.first).to eq(comp)
    end
  end
end
