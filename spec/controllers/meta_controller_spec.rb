require 'rails_helper'
require 'support/devise'

describe MetaController do
  describe 'GET #index' do
    let(:user) { create(:user) }

    before do
      user.grant(:edit, :games)
    end

    it 'returns http success' do
      sign_in user

      get :index

      expect(response).to have_http_status(:success)
    end
  end
end
