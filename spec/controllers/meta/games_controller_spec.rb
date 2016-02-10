require 'rails_helper'

describe Meta::GamesController do
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

      post :create, game: { name: 'Bar' }

      game = Game.first
      expect(game.name).to eq('Bar')
    end

    # TODO: Fail case
  end

  describe 'GET #show' do
    let(:game) { create(:game) }

    it 'succeeds' do
      get :show, id: game.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    let(:game) { create(:game) }

    it 'succeeds for authorized user' do
      sign_in admin

      get :edit, id: game.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let(:game) { create(:game) }

    it 'succeeds for authorized user' do
      sign_in admin

      patch :update, id: game.id, game: { name: 'A' }

      game = Game.first
      expect(game.name).to eq('A')
    end

    # TODO: Fail case
  end
end
