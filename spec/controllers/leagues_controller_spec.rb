require 'rails_helper'

describe LeaguesController do
  let(:admin) { create(:user) }

  before do
    admin.grant(:edit, :competitions)
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      sign_in admin

      get :new

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:format) { create(:format) }

    it 'returns http success' do
      sign_in admin

      post :create, competition: { name: 'A', description: 'B', format_id: format.id,
                                   signuppable: true, roster_locked: false,
                                   divisions_attributes: [
                                     { name: 'PREM',
                                       description: 'C',
                                       min_teams: 2,
                                       max_teams: 3,
                                       min_players: 1,
                                       max_players: 3 },
                                   ] }

      comp = Competition.first
      expect(comp.name).to eq('A')
      expect(comp.description).to eq('B')
      expect(comp.format).to eq(format)
      expect(comp.signuppable).to be(true)
      expect(comp.roster_locked).to be(false)
      expect(comp.divisions.size).to eq(1)
      div = comp.divisions.first
      expect(div.name).to eq('PREM')
      expect(div.description).to eq('C')
      expect(div.min_teams).to eq(2)
      expect(div.max_teams).to eq(3)
      expect(div.min_players).to eq(1)
      expect(div.max_players).to eq(3)
    end
  end

  describe 'GET #show' do
    let!(:comp) { create(:competition, private: false) }

    it 'returns http success' do
      get :show, id: comp.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    let(:comp) { create(:competition) }

    it 'returns http success' do
      sign_in admin

      get :edit, id: comp.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let(:comp) { create(:competition) }

    it 'returns http success' do
      sign_in admin

      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #visibility' do
    let(:comp) { create(:competition, private: true) }

    it 'returns http success' do

      sign_in admin

      patch :visibility, id: comp.id, private: false

      comp.reload
      expect(comp.public?).to eq(true)
    end
  end

  describe 'DELETE #destroy' do
    let(:comp) { create(:competition) }

    it 'succeeds for private competition' do
      sign_in admin

      delete :destroy, id: comp.id

      expect(Competition.count).to eq(0)
    end

    it 'fails for public competition' do
      comp.private = false
      comp.save!
      sign_in admin

      delete :destroy, id: comp.id

      expect(Competition.first).to eq(comp)
    end
  end
end
