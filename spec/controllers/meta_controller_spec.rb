require 'rails_helper'
require 'support/devise'

describe MetaController do
  describe 'GET #index' do
    it 'succeeds for authorized user' do
      user = create(:user)
      user.grant(:edit, :games)
      sign_in user

      get :index

      expect(response).to have_http_status(:success)
    end

    it 'redirects to root for unauthorized user' do
      user = create(:user)
      sign_in user

      get :index

      expect(response).to redirect_to(root_path)
    end

    it 'redirects to root for unauthenticated' do
      get :index

      expect(response).to redirect_to(root_path)
    end
  end
end
