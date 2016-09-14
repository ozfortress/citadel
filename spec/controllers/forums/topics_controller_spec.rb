require 'rails_helper'

describe Forums::TopicsController do
  let(:parent_topic) { create(:forums_topic) }
  let(:user) { create(:user) }

  describe 'GET #new' do
    it 'succeeds for authorized user' do
      user.grant(:manage, :forums)
      sign_in user

      get :new, params: { parent_topic: parent_topic.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      user.grant(:manage, :forums)
      sign_in user

      post :create, params: { forums_topic: { name: 'Foo', parent_topic_id: parent_topic.id } }

      expect(parent_topic.children).to_not be_empty
      topic = parent_topic.children.first
      expect(topic.name).to eq('Foo')
      expect(topic.created_by).to eq(user)
      expect(response).to redirect_to(forums_topic_path(topic))
    end

    it 'fails with invalid data' do
      user.grant(:manage, :forums)
      sign_in user

      post :create, params: { forums_topic: { name: '', parent_topic_id: parent_topic.id } }

      expect(parent_topic.children).to be_empty
    end

    it 'redirects for unauthorized user' do
      sign_in user

      post :create, params: { forums_topic: { name: 'Foo', parent_topic_id: parent_topic.id } }

      expect(response).to redirect_to(forums_path)
    end

    it 'redirects for unauthenticated user' do
      post :create, params: { forums_topic: { name: 'Foo', parent_topic_id: parent_topic.id } }

      expect(response).to redirect_to(forums_path)
    end
  end

  context 'Existing Topic' do
    let(:topic) { create(:forums_topic, parent_topic: parent_topic) }

    describe 'GET #show' do
      it 'succeeds' do
        get :show, params: { id: topic.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #edit' do
      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        get :edit, params: { id: topic.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH #update' do
      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        patch :update, params: { id: topic.id, forums_topic: { name: 'Test' } }

        topic.reload
        expect(topic.name).to eq('Test')
        expect(response).to redirect_to(forums_topic_path(topic))
      end
    end

    describe 'DELETE #destroy' do
      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        delete :destroy, params: { id: topic.id }

        expect(topic.children).to be_empty
        expect(response).to redirect_to(forums_topic_path(parent_topic))
      end
    end
  end
end
