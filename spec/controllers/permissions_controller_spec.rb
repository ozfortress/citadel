require 'rails_helper'

describe PermissionsController do
  let(:permission_admin) do
    user = create(:user)
    user.grant(:edit, :permissions)
    user
  end

  let(:user_admin) do
    user = create(:user)
    user.grant(:edit, :users)
    user
  end

  let(:team_admin) do
    user = create(:user)
    user.grant(:edit, :teams)
    user
  end

  let(:user) { create(:user) }

  describe 'GET #index' do
    it 'succeeds for authorized user' do
      sign_in permission_admin

      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #users' do
    let!(:users) { create_list(:user, 12) }

    it 'succeeds for authorized user' do
      sign_in permission_admin

      get :users, params: { action_: :edit, subject: :users }

      expect(response).to have_http_status(:success)
    end

    it 'succeeds for authorized user with target' do
      team = create(:team)
      sign_in team_admin

      get :users, params: { action_: :edit, subject: :team, target: team.id }

      expect(response).to have_http_status(:success)
    end

    it 'fails for authorized user with invalid target' do
      team = create(:team)
      sign_in team_admin

      expect do
        get :users, params: { action_: :edit, subject: :array, target: team.id }
      end.to raise_error NoMethodError
    end

    it 'redirects for admin without authorization' do
      team = create(:team)
      sign_in permission_admin

      get :users, params: { action_: :edit, subject: :team, target: team.id }

      expect(response).to redirect_to(permissions_path)
    end

    it 'redirects for unauthorized user' do
      team = create(:team)
      sign_in users.first

      get :users, params: { action_: :edit, subject: :team, target: team.id }

      expect(response).to redirect_to(permissions_path)
    end
  end

  describe 'POST #grant' do
    it 'succeeds for authorized user' do
      sign_in permission_admin

      post :grant, params: { action_: :edit, subject: :users, user_id: user.id }

      expect(user.can?(:edit, :users)).to be(true)
    end

    it 'succeeds for authorized user with team' do
      team = create(:team)
      team.add_player!(user)
      sign_in team_admin

      post :grant, params: { action_: :edit, subject: :team,
                             target: team.id, user_id: user.id }

      expect(user.can?(:edit, team)).to be(true)
    end

    it 'fails for authorized user with team for random user' do
      team = create(:team)
      sign_in team_admin

      expect do
        post :grant, params: { action_: :edit, subject: :team,
                               target: team.id, user_id: user.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'redirects for admin without authorization with team' do
      team = create(:team)
      team.add_player!(user)
      sign_in permission_admin

      post :grant, params: { action_: :edit, subject: :team,
                             target: team.id, user_id: user.id }

      expect(response).to redirect_to(permissions_path)
    end
  end

  describe 'DELETE #revoke' do
    it 'succeeds for authorized user' do
      user.grant(:edit, :users)
      sign_in permission_admin

      delete :revoke, params: { action_: :edit, subject: :users, user_id: user.id }

      user.reload
      expect(user.reload.can?(:edit, :users)).to be(false)
    end

    it 'succeeds for authorized user with team' do
      team = create(:team)
      team.add_player!(user)
      user.grant(:edit, team)
      sign_in team_admin

      delete :revoke, params: { action_: :edit, subject: :team,
                                target: team.id, user_id: user.id }

      expect(user.reload.can?(:edit, team)).to be(false)
    end

    it 'succeeds for authorized user with team for random user' do
      team = create(:team)
      user.grant(:edit, team)
      sign_in team_admin

      expect do
        delete :revoke, params: { action_: :edit, subject: :team,
                                  target: team.id, user_id: user.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'redirects for admin without authorization with team' do
      team = create(:team)
      team.add_player!(user)
      sign_in permission_admin

      post :revoke, params: { action_: :edit, subject: :team,
                              target: team.id, user_id: user.id }

      expect(response).to redirect_to(permissions_path)
    end
  end
end
