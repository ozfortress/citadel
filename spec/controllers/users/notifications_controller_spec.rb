require 'rails_helper'
require 'support/devise'
require 'support/omniauth'
require 'support/factory_girl'

describe Users::NotificationsController do
  describe 'GET #read' do
    let(:user) { create(:user) }
    let!(:notification) { create(:user_notification, user: user) }

    it 'succeeds for notified user' do
      sign_in user

      get :read, params: { id: notification.id }

      expect(response).to redirect_to(user_path(user))
    end

    it 'fails for non-notified user' do
      user2 = create(:user)
      sign_in user2

      expect do
        get :read, params: { id: notification.id }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it 'fails for unauthenticated user' do
      get :read, params: { id: notification.id }

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'DELETE #clear' do
    let(:user) { create(:user) }
    let!(:notifications) { create_list(:user_notification, 20, user: user) }

    it 'succeeds for notified user' do
      sign_in user

      delete :clear

      expect(response).to redirect_to(root_path)
      expect(user.notifications.unread).to be_empty
    end
  end
end
