require 'rails_helper'

describe Users::NotificationsController do
  let(:user) { create(:user) }

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
