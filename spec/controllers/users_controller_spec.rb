require 'rails_helper'

describe UsersController do
  describe 'GET #index' do
    let!(:users) { create_list(:user, 20) }

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

    it 'fails for unauthenticated user' do
      get :new

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'POST #create' do
    it 'creates a user' do
      session['devise.steam_data'] = OmniAuth.mock_auth_hash

      post :create, params: { user: {
        name: 'A', description: 'B', email: 'foo@bar.com',
      } }

      user = User.find_by(name: 'A')
      expect(user).to_not be_nil
      expect(user.description).to eq('B')
      expect(user.email).to eq('foo@bar.com')
      expect(user).to_not be_confirmed
    end

    it 'handles existing users' do
      user = create(:user, steam_id: 123)
      session['devise.steam_data'] = OmniAuth.mock_auth_hash(steam_id: 456)

      post :create, params: { user: { name: user.name, description: 'B' } }
    end
  end

  describe 'GET #profile' do
    let(:user) { create(:user) }

    it 'succeeds for signed in user' do
      sign_in user

      request.path = '/profile/edit?foo=bar'
      get :profile

      expect(response).to redirect_to(user_path(user) + '/edit?foo=bar')
    end

    it 'fails when unauthenticated' do
      request.path = '/profile/edit?foo=bar'
      get :profile

      expect(response).to redirect_to(root_path)
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
    let(:admin) { create(:user) }

    it 'updates a user' do
      sign_in user

      patch :update, params: { id: user.id, user: {
        description: 'D', badge_name: 'Foo', badge_color: 1, email: 'foo@bar.com', notice: 'foo'
      } }

      user.reload
      expect(user.description).to eq('D')
      expect(user.badge_name).to eq('')
      expect(user.badge_color).to eq(0)
      expect(user.notice).to eq('')
      expect(user.email).to eq('foo@bar.com')
      expect(user).to_not be_confirmed
      expect(response).to redirect_to(user_path(user))
    end

    it 'allows admins to edit users' do
      admin.grant(:edit, :users)
      sign_in admin

      patch :update, params: { id: user.id, user: {
        description: 'D', badge_name: 'Foo', badge_color: 1, notice: 'foo'
      } }

      user.reload
      expect(user.description).to eq('D')
      expect(user.badge_name).to eq('Foo')
      expect(user.badge_color).to eq(1)
      expect(user.notice).to eq('foo')
      expect(response).to redirect_to(user_path(user))
    end

    it 'allows avatar removal' do
      sign_in user

      patch :update, params: { id: user.id, user: { remove_avatar: true } }

      user.reload
      expect(user.avatar.url).to eq(user.avatar.default_url)
    end

    it 'sends a confirmation email when email is set' do
      sign_in user

      patch :update, params: { id: user.id, user: { email: 'foo@bar.com' } }

      expect(controller).to set_flash[:notice]
      expect(ActionMailer::Base.deliveries).to_not be_empty
    end

    it 'redirects for unauthorized user' do
      sign_in user

      patch :update, params: { id: admin.id, user: { description: 'D' } }

      user.reload
      expect(user.description).to eq('B')
      expect(response).to redirect_to(user_path(admin))
    end

    it 'redirects for banned user' do
      sign_in user
      user.ban(:use, :users)

      patch :update, params: { id: user.id, user: { description: 'D' } }

      user.reload
      expect(user.description).to eq('B')
      expect(response).to redirect_to(user_path(user))
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
      expect(user.names.pending.size).to eq(0)

      post :request_name_change, params: { id: user.id, name_change: { name: 'B' } }

      expect(user.names.pending.size).to eq(1)
      name_change = user.names.pending.first
      expect(name_change.name).to eq('B')
      expect(name_change.approved_by).to be_nil
      expect(name_change.denied_by).to be_nil
    end

    it 'fails for identical name' do
      sign_in user

      post :request_name_change, params: { id: user.id, name_change: { name: 'A' } }

      expect(user.names.pending.size).to eq(0)
    end

    it 'fails if name change is already pending' do
      create(:user_name_change, user: user, name: 'B')
      sign_in user

      post :request_name_change, params: { id: user.id, name_change: { name: 'C' } }

      expect(user.names.pending.size).to eq(1)
    end

    it 'redirects for unauthorized user' do
      other = create(:user)
      sign_in other

      post :request_name_change, params: { id: user.id, name_change: { name: 'B' } }

      expect(user.names.pending).to be_empty
      expect(response).to redirect_to(user_path(user))
    end

    it 'redirects for banned user' do
      sign_in user
      user.ban(:use, :users)

      post :request_name_change, params: { id: user.id, name_change: { name: 'B' } }

      expect(user.names.pending).to be_empty
      expect(response).to redirect_to(user_path(user))
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

      user.reload
      expect(user.name).to eq('B')
      expect(user.names.pending.size).to eq(0)
      expect(user.names.approved.where(name: 'B')).to exist
      expect(user.notifications).to_not be_empty
    end

    it 'denies name changes' do
      sign_in admin

      patch :handle_name_change, params: {
        user_id: user.id, id: name_change.id, approve: 'false'
      }

      user.reload
      expect(user.name).to eq('A')
      expect(user.names.pending.size).to eq(0)
      expect(user.names.approved.where(name: 'B')).to_not exist
      expect(user.notifications).to_not be_empty
    end

    it 'redirects for unauthorized user' do
      sign_in user

      patch :handle_name_change, params: {
        user_id: user.id, id: name_change.id, approve: 'true'
      }

      user.reload
      expect(user.name).to eq('A')
    end
  end

  describe 'GET #confirm_email' do
    let(:user) { create(:user, email: 'foo@bar.com') }

    it 'succeeds' do
      token = user.generate_confirmation_token
      user.save!

      patch :confirm_email, params: { token: token }

      user.reload
      expect(user).to be_confirmed
      expect(controller).to set_flash[:notice]
      expect(response).to redirect_to(user_path(user))
    end

    it 'fails after timeout' do
      token = user.generate_confirmation_token
      user.save!

      # Jump an hour into the future
      allow(Time).to receive(:current).and_return(Time.current + 1.hour)

      patch :confirm_email, params: { token: token }

      user.reload
      expect(user).to_not be_confirmed
      expect(user.email).to be_nil
      expect(controller).to set_flash[:error]
      expect(response).to redirect_to(user_path(user))
    end

    it 'fails with invalid token' do
      patch :confirm_email, params: { token: 'guarbage' }

      expect(controller).to set_flash[:error]
      expect(response).to redirect_to(root_path)
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
