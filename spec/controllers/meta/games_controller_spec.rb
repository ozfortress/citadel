require 'rails_helper'

describe Meta::GamesController do
  let(:admin) { create(:user) }
  let(:user) { create(:user) }

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

      post :create, params: { game: { name: 'Bar' } }

      game = Game.first
      expect(game.name).to eq('Bar')
      expect(response).to redirect_to(meta_game_path(game))
    end

    it 'fails for invalid data' do
      sign_in admin

      post :create, params: { game: { name: '' } }

      expect(Game.all).to be_empty
      expect(response).to have_http_status(:success)
    end

    it 'redirects for unauthorized user' do
      sign_in user

      post :create, params: { game: { name: 'Bar' } }

      expect(Game.all).to be_empty
      expect(response).to redirect_to(root_path)
    end
  end

  context 'existing game' do
    let(:game) { create(:game) }

    describe 'GET #show' do
      it 'succeeds' do
        get :show, params: { id: game.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #edit' do
      it 'succeeds for authorized user' do
        sign_in admin

        get :edit, params: { id: game.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH #update' do
      it 'succeeds for authorized user' do
        sign_in admin

        patch :update, params: { id: game.id, game: { name: 'A' } }

        game = Game.first
        expect(game.name).to eq('A')
      end

      it 'fails for invalid data' do
        sign_in admin

        patch :update, params: { id: game.id, game: { name: '' } }

        game = Game.first
        expect(game.name).to_not eq('')
        expect(response).to have_http_status(:success)
      end

      it 'redirects for unauthorized user' do
        sign_in user

        patch :update, params: { id: game.id, game: { name: 'Bar' } }

        game = Game.first
        expect(game.name).to_not eq('Bar')
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
