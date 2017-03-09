require 'rails_helper'

describe Users::NotificationsController do
  describe 'GET #show' do
    let(:user) { create(:user) }
    let!(:notification) { create(:user_notification, user: user) }

    it 'succeeds for notified user' do
      sign_in user

      get :show, params: { id: notification.id }

      expect(response).to redirect_to(user_path(user))
    end

    it 'fails for non-notified user' do
      user2 = create(:user)
      sign_in user2

      expect do
        get :show, params: { id: notification.id }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it 'fails for unauthenticated user' do
      get :show, params: { id: notification.id }

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'DELETE #clear' do
    let(:user) { create(:user) }
    let!(:notifications) { create_list(:user_notification, 5, user: user) }

    it 'succeeds for notified user' do
      sign_in user

      delete :clear

      expect(user.notifications).to be_empty
      expect(response).to have_http_status(:success)
    end
  end
end
