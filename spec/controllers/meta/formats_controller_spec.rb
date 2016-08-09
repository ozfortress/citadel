require 'rails_helper'

describe Meta::FormatsController do
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

      post :create, params: {
        format_: { game_id: game.id, player_count: 3, name: 'Foo', description: 'Bar' }
      }

      format = Format.first
      expect(format.game).to eq(game)
      expect(format.player_count).to eq(3)
      expect(format.name).to eq('Foo')
      expect(format.description).to eq('Bar')
    end

    # TODO: Fail case
  end

  describe 'GET #show' do
    let(:format) { create(:format, game: game) }

    it 'succeeds' do
      get :show, params: { id: format.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    let(:format) { create(:format, game: game) }

    it 'succeeds for authorized user' do
      sign_in admin

      get :edit, params: { id: format.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let(:format) { create(:format, game: game) }
    let!(:game2) { create(:game) }

    it 'succeeds for authorized user' do
      sign_in admin

      patch :update, params: {
        id: format.id, format_: { game_id: game2.id, player_count: 1,
                                  name: 'A', description: 'B' }
      }

      format = Format.first
      expect(format.game).to eq(game2)
      expect(format.player_count).to eq(1)
      expect(format.name).to eq('A')
      expect(format.description).to eq('B')
    end

    # TODO: Fail case
  end
end
