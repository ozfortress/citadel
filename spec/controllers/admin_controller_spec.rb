require 'rails_helper'

describe AdminController do
  describe 'GET #index' do
    let(:user) { create(:user) }

    it 'succeeds for authorized user' do
      user.grant(:edit, :games)
      sign_in user

      get :index

      expect(response).to have_http_status(:success)
    end

    it 'redirects to root for unauthorized user' do
      sign_in user

      get :index

      expect(response).to redirect_to(root_path)
    end

    it 'redirects to root for unauthenticated' do
      get :index

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET #logs' do
    let(:user) { create(:user) }
    let(:visit) { create(:visit, user: user) }
    let!(:events) { create_list(:ahoy_event, 50, user: user, visit: visit) }

    it 'succeeds for authorized' do
      user.grant(:edit, :games)
      sign_in user

      get :logs

      expect(response).to have_http_status(:success)
    end
  end
end
