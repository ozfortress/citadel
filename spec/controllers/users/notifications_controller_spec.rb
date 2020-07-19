require 'rails_helper'

describe Users::NotificationsController do
  let(:user) { create(:user) }

  describe 'POST #create' do
    let(:admin) { create(:user) }

    it 'succeeds for admin' do
      admin.grant(:edit, :users)
      sign_in admin

      post :create, params: {
        user_id: user.id, notification: { message: 'Test Notify', link: 'http://example.com/test' }
      }

      expect(user.notifications).to_not be_empty
      notification = user.notifications.first
      expect(notification.message).to eq('Test Notify')
      expect(notification.link).to eq('http://example.com/test')
    end

    it 'fails for non-admin' do
      sign_in admin

      post :create, params: {
        user_id: user.id, notification: { message: 'Test Notify', link: 'http://example.com/test' }
      }

      expect(user.notifications).to be_empty
    end

    it 'fails for unauthenticated user' do
      post :create, params: {
        user_id: user.id, notification: { message: 'Test Notify', link: 'http://example.com/test' }
      }

      expect(user.notifications).to be_empty
    end
  end

  context 'single notification' do
    let!(:notification) { create(:user_notification, user: user) }

    describe 'GET #show' do
      it 'succeeds for notified user' do
        sign_in user

        get :show, params: { id: notification.id }

        expect(user.notifications).to eq([notification])
        expect(notification.reload.read).to be(true)
        expect(response).to redirect_to(user_path(user))
      end

      it 'fails for non-notified user' do
        sign_in create(:user)

        expect do
          get :show, params: { id: notification.id }
        end.to raise_error ActiveRecord::RecordNotFound
      end

      it 'fails for unauthenticated user' do
        get :show, params: { id: notification.id }

        expect(response).to redirect_to(root_path)
      end
    end

    describe 'DELETE #destroy' do
      it 'succeeds for notified user' do
        sign_in user

        delete :destroy, params: { id: notification.id }

        expect(user.notifications).to be_empty
        expect(response).to have_http_status(:success)
      end
    end
  end

  context 'many notifications' do
    let!(:notifications) { create_list(:user_notification, 5, user: user) }

    describe 'GET #index' do
      it 'succeeds for notified user' do
        sign_in user

        get :index, xhr: true

        expect(Set.new(user.notifications)).to eq(Set.new(notifications))
        expect(response).to have_http_status(:success)
      end
    end

    describe 'DELETE #clear' do
      it 'succeeds for notified user' do
        sign_in user

        delete :clear

        expect(user.notifications).to be_empty
        expect(response).to have_http_status(:success)
      end
    end
  end
end
