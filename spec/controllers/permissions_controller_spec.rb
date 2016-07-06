require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe PermissionsController do
  let(:admin) { create(:user) }
  let(:user) { create(:user) }

  before do
    admin.grant(:edit, :permissions)
  end

  describe 'GET #index' do
    it 'succeeds for authorized user' do
      sign_in admin

      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #users' do
    let!(:users) { create_list(:user, 12) }

    it 'succeeds for authorized user' do
      sign_in admin

      get :users, action_: :edit, subject: :users

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #grant' do
    it 'succeeds for authorized user' do
      sign_in admin

      post :grant, action_: :edit, subject: :users, user_id: user.id

      expect(user.can?(:edit, :users)).to be(true)
    end
  end

  describe 'DELETE #revoke' do
    it 'succeeds for authorized user' do
      user.grant(:edit, :users)
      sign_in admin

      delete :revoke, action_: :edit, subject: :users, user_id: user.id

      expect(user.can?(:edit, :users)).to be(false)
    end
  end
end
