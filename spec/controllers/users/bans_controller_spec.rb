require 'rails_helper'

describe Users::BansController do
  let(:user) { create(:user) }
  let(:admin) { create(:user) }

  describe 'GET #index' do
    it 'succeeds for authorized user' do
      admin.grant(:edit, :users)
      sign_in admin

      get :index, params: { user_id: user.id }

      expect(response).to have_http_status(:success)
    end

    it 'redirects for unauthorized user' do
      sign_in admin

      get :index, params: { user_id: user.id }

      expect(response).to redirect_to(user_path(user))
    end

    it 'redirects for unauthenticated user' do
      get :index, params: { user_id: user.id }

      expect(response).to redirect_to(user_path(user))
    end
  end

  describe 'POST #create' do
    # Need to round off to the nearest second
    let(:terminated_at) { Time.zone.at((Time.zone.now + 2.days).to_i) }

    it 'succeeds for authorized user' do
      admin.grant(:edit, :users)
      sign_in admin

      post :create, params: { user_id: user.id, ban: { reason: 'foo', terminated_at: terminated_at },
                              action_: :use, subject: :leagues }

      expect(user.can?(:use, :leagues)).to be false
      bans = user.bans_for(:use, :leagues)
      expect(bans.size).to eq(1)
      ban = bans.first
      expect(ban.reason).to eq('foo')
      expect(ban.terminated_at).to eq(terminated_at)
      expect(response).to redirect_to(user_bans_path(user))
    end

    it 'fails for authorized user with invalid data' do
      admin.grant(:edit, :users)
      sign_in admin

      terminated_at = Time.zone.now - 2.days
      post :create, params: { user_id: user.id, ban: { reason: 'foo', terminated_at: terminated_at },
                              action_: :use, subject: :leagues }

      expect(user.can?(:use, :leagues)).to be true
      expect(response).to have_http_status(:success)
    end

    it 'redirects for unauthorized user' do
      sign_in admin

      post :create, params: { user_id: user.id, ban: { reason: 'foo', terminated_at: terminated_at },
                              action_: :use, subject: :leagues }

      expect(response).to redirect_to(user_path(user))
    end

    it 'redirects for unauthenticated user' do
      post :create, params: { user_id: user.id, ban: { reason: 'foo', terminated_at: terminated_at },
                              action_: :use, subject: :leagues }

      expect(response).to redirect_to(user_path(user))
    end
  end

  describe 'DELETE #destroy' do
    let(:ban) do
      user.ban(:use, :leagues, reason: 'bar')

      user.bans_for(:use, :leagues).first
    end

    it 'succeeds for authorized user' do
      admin.grant(:edit, :users)
      sign_in admin

      delete :destroy, params: { user_id: user.id, id: ban.id, action_: :use, subject: :leagues }

      user.reload
      expect(user.actively_banned?(:use, :leagues)).to be false
      expect(user.bans_for(:use, :leagues)).to be_empty
      expect(response).to redirect_to(user_bans_path(user))
    end

    it 'redirects for unauthorized user' do
      sign_in admin

      delete :destroy, params: { user_id: user.id, id: ban.id, action_: :use, subject: :leagues }

      expect(response).to redirect_to(user_path(user))
    end

    it 'redirects for unauthenticated user' do
      delete :destroy, params: { user_id: user.id, id: ban.id, action_: :use, subject: :leagues }

      expect(response).to redirect_to(user_path(user))
    end
  end
end
