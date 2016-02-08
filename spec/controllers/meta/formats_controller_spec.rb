require 'rails_helper'

describe Meta::FormatsController do
  let(:game) { create(:game) }
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

      post :create, format_: { game_id: game.id, player_count: 3,
                              name: 'Foo', description: 'Bar'}

      format = Format.first
      expect(format.game).to eq(game)
      expect(format.player_count).to eq(3)
      expect(format.name).to eq('Foo')
      expect(format.description).to eq('Bar')
    end
  end
end
