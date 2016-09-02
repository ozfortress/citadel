require 'rails_helper'

describe Forums::ThreadsController do
  let(:topic) { create(:forums_topic) }
  let(:user) { create(:user) }

  describe 'GET #new' do
    it 'succeeds for authorized user' do
      user.grant(:manage, :forums)
      sign_in user

      get :new, params: { topic: topic.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      user.grant(:manage, :forums)
      sign_in user

      post :create, params: { forums_thread: { title: 'Foo', topic_id: topic.id } }

      expect(topic.threads).to_not be_empty
      thread = topic.threads.first
      expect(thread.title).to eq('Foo')
      expect(thread.created_by).to eq(user)
      expect(response).to redirect_to(forums_thread_path(thread))
    end

    it 'fails with invalid data' do
      user.grant(:manage, :forums)
      sign_in user

      post :create, params: { forums_thread: { title: '', topic_id: topic.id } }

      expect(topic.threads).to be_empty
    end

    it 'redirects for unauthorized user' do
      sign_in user

      post :create, params: { forums_thread: { title: 'Foo', topic_id: topic.id } }

      expect(response).to redirect_to(forums_path)
    end

    it 'redirects for unauthenticated user' do
      post :create, params: { forums_thread: { title: 'Foo', topic_id: topic.id } }

      expect(response).to redirect_to(forums_path)
    end
  end

  context 'Existing Thread' do
    let(:thread) { create(:forums_thread, topic: topic) }

    describe 'GET #show' do
      it 'succeeds' do
        get :show, params: { id: thread.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #edit' do
      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        get :edit, params: { id: thread.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH #update' do
      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        patch :update, params: { id: thread.id, forums_thread: { title: 'Test' } }

        thread.reload
        expect(thread.title).to eq('Test')
        expect(response).to redirect_to(forums_thread_path(thread))
      end
    end

    describe 'DELETE #destroy' do
      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        delete :destroy, params: { id: thread.id }

        expect(topic.threads).to be_empty
        expect(response).to redirect_to(forums_topic_path(topic))
      end
    end
  end
end
