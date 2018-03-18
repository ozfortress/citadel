require 'rails_helper'

describe Meta::FormatsController do
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

      post :create, params: {
        format_: { game_id: @game.id, player_count: 3, name: 'Foo', description: 'Bar' },
      }

      format = Format.first
      expect(format.game).to eq(@game)
      expect(format.player_count).to eq(3)
      expect(format.name).to eq('Foo')
      expect(format.description).to eq('Bar')
      expect(response).to redirect_to(meta_format_path(format))
    end

    it 'fails for invalid data' do
      sign_in @admin

      post :create, params: {
        format_: { game_id: @game.id, player_count: 0, name: '' },
      }

      expect(Format.all).to be_empty
      expect(response).to have_http_status(:success)
    end

    it 'redirects for unauthorized user' do
      sign_in @user

      post :create, params: {
        format_: { game_id: @game.id, player_count: 0, name: '' },
      }

      expect(Format.all).to be_empty
      expect(response).to redirect_to(root_path)
    end
  end

  context 'existing format' do
    before(:all) do
      @game2 = create(:game)
    end

    let!(:format) { create(:format, game: @game) }

    describe 'GET #show' do
      it 'succeeds' do
        get :show, params: { id: format.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #edit' do
      it 'succeeds for authorized user' do
        sign_in @admin

        get :edit, params: { id: format.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH #update' do
      it 'succeeds for authorized user' do
        sign_in @admin

        patch :update, params: {
          id: format.id, format_: { game_id: @game2.id, player_count: 1,
                                    name: 'A', description: 'B' }
        }

        format.reload
        expect(format.game).to eq(@game2)
        expect(format.player_count).to eq(1)
        expect(format.name).to eq('A')
        expect(format.description).to eq('B')
        expect(response).to redirect_to(meta_format_path(format))
      end

      it 'fails for invalid data' do
        sign_in @admin

        patch :update, params: {
          id: format.id, format_: { game_id: @game2.id, player_count: 0, name: '' }
        }

        format.reload
        expect(format.game).to eq(@game)
        expect(format.player_count).to_not eq(0)
        expect(format.name).to_not eq('')
        expect(response).to have_http_status(:success)
      end

      it 'redirects for unauthorized user' do
        sign_in @user

        patch :update, params: { id: format.id, format_: { game_id: @game2.id } }

        format.reload
        expect(format.game).to eq(@game)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
