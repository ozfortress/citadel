require 'rails_helper'
require 'support/devise'
require 'support/omniauth'

describe UsersController do
  describe 'GET #index' do
    it 'succeeds' do
      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'succeeds' do
      session['devise.steam_data'] = OmniAuth.mock_auth_hash

      get :new

      expect(response).to have_http_status(:success)
    end

    it 'fails for unauthenticated user'
  end

  describe 'POST #create' do
    it 'creates a user' do
      session['devise.steam_data'] = OmniAuth.mock_auth_hash

      post :create, user: { name: 'A', description: 'B' }

      user = User.find_by(name: 'A')
      expect(user).to_not be_nil
      expect(user.description).to eq('B')
    end

    it 'handles existing users' do
      user = create(:user, steam_id: 123)
      session['devise.steam_data'] = OmniAuth.mock_auth_hash(steam_id: 456)

      post :create, user: { name: user.name, description: 'B' }

      expect(response).to render_template(:new)
    end
  end

  describe 'GET #show' do
    it 'succeeds' do
      user = create(:user)

      get :show, id: user.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'succeeds' do
      user = create(:user)

      sign_in user
      get :edit, id: user.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    it 'updates a user' do
      user = create(:user, name: 'A', description: 'B')

      sign_in user
      patch :update, id: user.id, user: { name: 'C', description: 'D' }

      user = User.find(user.id)
      expect(user).to_not be_nil
      expect(user.name).to eq('C')
      expect(user.description).to eq('D')
    end
  end

  describe 'PATCH #logout' do
    it 'logs a user out' do
      user = create(:user)

      sign_in user
      request.env['HTTP_REFERER'] = '/'
      patch :logout

      expect(session['devise']).to be_nil
    end
  end
end
