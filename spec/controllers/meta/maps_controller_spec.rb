require 'rails_helper'

describe Meta::MapsController do
  let!(:game) { create(:game) }
  let(:admin) { create(:user) }

  before do
    admin.grant(:edit, :games)
  end

  describe 'GET #index' do
    it 'succeeds for authorized user' do
      sign_in admin

      get :index

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
    it 'succeeds for authorized user' do
      sign_in admin

      post :create, params: { map: { game_id: game.id, name: 'Foo', description: 'Bar' } }

      map = Map.first
      expect(map.game).to eq(game)
      expect(map.name).to eq('Foo')
      expect(map.description).to eq('Bar')
    end

    # TODO: Fail case
  end

  describe 'GET #show' do
    let(:map) { create(:map, game: game) }

    it 'succeeds' do
      get :show, params: { id: map.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    let(:map) { create(:map, game: game) }

    it 'succeeds for authorized user' do
      sign_in admin

      get :edit, params: { id: map.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let(:map) { create(:map, game: game) }
    let!(:game2) { create(:game) }

    it 'succeeds for authorized user' do
      sign_in admin

      patch :update, params: {
        id: map.id, map: { game_id: game2.id, name: 'A', description: 'B' }
      }

      map = Map.first
      expect(map.game).to eq(game2)
      expect(map.name).to eq('A')
      expect(map.description).to eq('B')
    end

    # TODO: Fail case
  end
end
