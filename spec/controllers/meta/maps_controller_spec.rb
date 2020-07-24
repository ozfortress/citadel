require 'rails_helper'

describe Meta::MapsController do
  before(:all) do
    @game = create(:game)

    @admin = create(:user)
    @admin.grant(:edit, :games)

    @user = create(:user)
  end

  describe 'GET #index' do
    it 'succeeds for authorized user' do
      sign_in @admin

      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'succeeds for authorized user' do
      sign_in @admin

      get :new

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      sign_in @admin

      post :create, params: { map: { game_id: @game.id, name: 'Foo', description: 'Bar' } }

      map = Map.first
      expect(map.game).to eq(@game)
      expect(map.name).to eq('Foo')
      expect(map.description).to eq('Bar')
      expect(response).to redirect_to(meta_map_path(map))
    end

    it 'fails for invalid data' do
      sign_in @admin

      post :create, params: { map: { game_id: @game.id, name: '' } }

      expect(Map.all).to be_empty
      expect(response).to have_http_status(:success)
    end

    it 'redirects for unauthorized user' do
      sign_in @user

      post :create, params: { map: { game_id: @game.id, name: 'Foo', description: 'Bar' } }

      expect(Map.all).to be_empty
      expect(response).to redirect_to(root_path)
    end
  end

  context 'existing map' do
    before(:all) do
      @game2 = create(:game)
    end

    let!(:map) { create(:map, game: @game) }

    describe 'GET #show' do
      it 'succeeds' do
        get :show, params: { id: map.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #edit' do
      it 'succeeds for authorized user' do
        sign_in @admin

        get :edit, params: { id: map.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH #update' do
      it 'succeeds for authorized user' do
        sign_in @admin

        patch :update, params: {
          id: map.id, map: { game_id: @game2.id, name: 'A', description: 'B' }
        }

        map.reload
        expect(map.game).to eq(@game2)
        expect(map.name).to eq('A')
        expect(map.description).to eq('B')
        expect(response).to redirect_to(meta_map_path(map))
      end

      it 'fails for invalid data' do
        sign_in @admin

        patch :update, params: {
          id: map.id, map: { game_id: @game2.id, name: '' }
        }

        map.reload
        expect(map.game).to eq(@game)
        expect(map.name).to_not eq('')
        expect(response).to have_http_status(:success)
      end

      it 'redirects for unauthorized user' do
        sign_in @user

        post :create, params: { map: { game_id: @game.id, name: 'Foo' } }

        map.reload
        expect(map.game).to eq(@game)
        expect(map.name).to_not eq('Foo')
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'DELETE #destroy' do
      it 'succeeds for authorized user' do
        sign_in @admin

        delete :destroy, params: { id: map.id }

        expect(Map.all).to be_empty
      end

      it 'fails for unauthorized user' do
        sign_in @user

        delete :destroy, params: { id: map.id }

        expect(Map.all).to_not be_empty
      end

      it 'fails for unauthenticated user' do
        delete :destroy, params: { id: map.id }

        expect(Map.all).to_not be_empty
      end
    end
  end
end
