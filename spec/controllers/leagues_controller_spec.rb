require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

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
      get :index, q: 'foo'

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

      post :create, league: { name: 'A', description: 'B', format_id: format.id,
                              signuppable: true, roster_locked: false,
                              matches_submittable: true, transfers_require_approval: false,
                              allow_set_draws: true, allow_disbanding: true,
                              min_players: 1, max_players: 3,
                              points_per_set_won: 3, points_per_set_drawn: 2,
                              points_per_set_lost: 1, points_per_match_forfeit_loss: 5,
                              points_per_match_forfeit_win: 6,
                              divisions_attributes: [{ name: 'PREM' }] }

      comp = League.first
      expect(comp.name).to eq('A')
      expect(comp.description).to eq('B')
      expect(comp.format).to eq(format)
      expect(comp.signuppable).to be(true)
      expect(comp.roster_locked).to be(false)
      expect(comp.matches_submittable).to be(true)
      expect(comp.transfers_require_approval).to be(false)
      expect(comp.allow_set_draws).to be(true)
      expect(comp.allow_disbanding).to be(true)
      expect(comp.min_players).to eq(1)
      expect(comp.max_players).to eq(3)
      expect(comp.points_per_set_won).to eq(3)
      expect(comp.points_per_set_drawn).to eq(2)
      expect(comp.points_per_set_lost).to eq(1)
      expect(comp.points_per_match_forfeit_loss).to eq(5)
      expect(comp.points_per_match_forfeit_win).to eq(6)
      expect(comp.divisions.size).to eq(1)
      div = comp.divisions.first
      expect(div.name).to eq('PREM')
    end

    it 'fails for invalid data' do
      sign_in admin

      post :create, league: { name: 'A', description: 'B', format_id: format.id,
                              signuppable: true, roster_locked: false,
                              matches_submittable: true,
                              min_players: 5, max_players: 3,
                              divisions_attributes: [
                                { name: 'PREM' },
                              ] }

      expect(League.first).to be(nil)
      expect(response).to render_template(:new)
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
      get :show, id: comp.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    let(:comp) { create(:league) }

    it 'succeeds for authorized user' do
      sign_in admin

      get :edit, id: comp.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let(:format) { create(:format) }
    let(:format2) { create(:format) }
    let(:comp) { create(:league, format: format) }

    it 'succeeds for authorized user' do
      sign_in admin

      patch :update, id: comp.id,
                     league: { name: 'A', description: 'B', format_id: format2.id,
                               signuppable: true, roster_locked: false,
                               matches_submittable: true,
                               transfers_require_approval: false,
                               min_players: 1, max_players: 3,
                               divisions_attributes: [
                                 { name: 'PREM' },
                               ] }

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

      patch :update, id: comp.id,
                     league: { name: '', description: 'B', format_id: format.id,
                               signuppable: true, roster_locked: false,
                               matches_submittable: true,
                               min_players: 5, max_players: 3,
                               divisions_attributes: [
                                 { name: 'PREM' },
                               ] }

      comp.reload
      expect(comp.name).not_to eq('')
      expect(response).to render_template(:edit)
    end

    it 'redirects for unauthorized user' do
      sign_in create(:user)

      patch :update, id: comp.id

      expect(response).to redirect_to(league_path(comp))
    end
  end

  describe 'PATCH #status' do
    let(:comp) { create(:league, status: :hidden) }

    it 'succeeds for authorized user' do
      sign_in admin

      patch :status, id: comp.id, status: 'running'

      comp.reload
      expect(comp.status).to eq('running')
    end
  end

  describe 'DELETE #destroy' do
    let(:comp) { create(:league) }

    it 'succeeds for hidden league' do
      sign_in admin

      delete :destroy, id: comp.id

      expect(League.count).to eq(0)
    end

    it 'fails for public league' do
      comp.status = 'running'
      comp.save!
      sign_in admin

      delete :destroy, id: comp.id

      expect(League.first).to eq(comp)
    end
  end
end
