require 'rails_helper'

describe UsersController do
  describe 'GET #index' do
    let!(:users) { create_list(:user, 50) }

    it 'succeeds' do
      get :index

      expect(response).to have_http_status(:success)
    end

    it 'succeeds with search' do
      get :index, params: { q: 'foo' }

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

      post :create, params: { user: { name: 'A', description: 'B' } }

      user = User.find_by(name: 'A')
      expect(user).to_not be_nil
      expect(user.description).to eq('B')
    end

    it 'handles existing users' do
      user = create(:user, steam_id: 123)
      session['devise.steam_data'] = OmniAuth.mock_auth_hash(steam_id: 456)

      post :create, params: { user: { name: user.name, description: 'B' } }
    end
  end

  describe 'GET #show' do
    let(:user) { create(:user) }

    it 'succeeds' do
      get :show, params: { id: user.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    let(:user) { create(:user) }

    it 'succeeds' do
      sign_in user

      get :edit, params: { id: user.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let(:user) { create(:user_with_avatar, description: 'B') }

    it 'updates a user' do
      sign_in user

      patch :update, params: { id: user.id, user: { description: 'D' } }

      user.reload
      expect(user).to_not be_nil
      expect(user.description).to eq('D')
    end

    it 'allows avatar removal' do
      sign_in user

      patch :update, params: { id: user.id, user: { remove_avatar: true } }

      user.reload
      expect(user.avatar.url).to eq(user.avatar.default_url)
    end
  end

  describe 'GET #names' do
    let(:user) { create(:user) }

    it 'succeeds for authorized user' do
      user.grant(:edit, :users)
      sign_in user

      get :names

      expect(response).to have_http_status(:success)
    end

    it 'redirects for unauthorized user' do
      sign_in user

      get :names

      expect(response).to redirect_to(pages_home_path)
    end

    it 'redirects for public' do
      get :names

      expect(response).to redirect_to(pages_home_path)
    end
  end

  describe 'POST #request_name_change' do
    let(:user) { create(:user, name: 'A') }

    it 'creates name change for authorized user' do
      sign_in user
      expect(user.pending_names.size).to eq(0)

      post :request_name_change, params: { id: user.id, name_change: { name: 'B' } }

      expect(user.pending_names.size).to eq(1)
      name_change = user.pending_names.first
      expect(name_change.name).to eq('B')
      expect(name_change.approved_by).to be_nil
      expect(name_change.denied_by).to be_nil
    end

    it 'fails for identical name' do
      sign_in user

      post :request_name_change, params: { id: user.id, name_change: { name: 'A' } }

      expect(user.pending_names.size).to eq(0)
    end

    it 'fails if name change is already pending' do
      create(:user_name_change, user: user, name: 'B')
      sign_in user

      post :request_name_change, params: { id: user.id, name_change: { name: 'C' } }

      expect(user.pending_names.size).to eq(1)
    end
  end

  describe 'PATCH #handle_name_change' do
    let(:user) { create(:user, name: 'A') }
    let(:name_change) { create(:user_name_change, user: user, name: 'B') }
    let(:admin) { create(:user) }
    before { admin.grant(:edit, :users) }

    it 'accepts name changes' do
      sign_in admin

      patch :handle_name_change, params: {
        user_id: user.id, id: name_change.id, approve: 'true'
      }

      usr = User.find(user.id)
      expect(usr.name).to eq('B')
      expect(usr.pending_names.size).to eq(0)
      expect(usr.approved_names.where(name: 'B')).to exist
    end

    it 'denies name changes' do
      sign_in admin

      patch :handle_name_change, params: {
        user_id: user.id, id: name_change.id, approve: 'false'
      }

      expect(user.name).to eq('A')
      expect(user.pending_names.size).to eq(0)
      expect(user.approved_names.where(name: 'B')).to_not exist
    end
  end

  describe 'PATCH #logout' do
    let(:user) { create(:user) }

    it 'logs a user out' do
      sign_in user
      request.env['HTTP_REFERER'] = '/'

      patch :logout

      expect(session['devise']).to be_nil
    end
  end
end
