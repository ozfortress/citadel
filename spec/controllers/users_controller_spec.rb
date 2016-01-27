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

  describe 'GET #show' do
    it 'succeeds' do
      user = create(:user)

      get :show, id: user.id

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'succeeds' do
      mock_auth_hash

      get :new

      expect(response).to have_http_status(:success)
    end

    it 'fails for unauthenticated user'
  end
end
