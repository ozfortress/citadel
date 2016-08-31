require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe Forums::PostsController do
  let(:topic) { create(:forums_topic) }
  let(:thread) { create(:forums_thread, topic: topic) }
  let(:user) { create(:user) }

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      user.grant(:manage, :forums)
      sign_in user

      post :create, params: { thread_id: thread.id, forums_post: { content: 'Foo' } }

      expect(thread.posts).to_not be_empty
      post = thread.posts.first
      expect(post.content).to eq('Foo')
      expect(post.created_by).to eq(user)
    end

    it 'fails with invalid data' do
      user.grant(:manage, :forums)
      sign_in user

      post :create, params: { thread_id: thread.id, forums_post: { content: '' } }

      expect(thread.posts).to be_empty
    end

    it 'redirects for unauthorized user' do
      sign_in user

      post :create, params: { thread_id: thread.id, forums_post: { content: 'Foo' } }

      expect(response).to redirect_to(forums_path)
    end

    it 'redirects for unauthenticated user' do
      post :create, params: { thread_id: thread.id, forums_post: { content: 'Foo' } }

      expect(response).to redirect_to(forums_path)
    end
  end

  context 'Existing Post' do
    let!(:post) { create(:forums_post, thread: thread) }

    describe 'GET #edit' do
      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        get :edit, params: { id: post.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH #update' do
      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        patch :update, params: { id: post.id, forums_post: { content: 'Test' } }

        post.reload
        expect(post.content).to eq('Test')
        expect(response).to redirect_to(forums_thread_path(thread))
      end
    end

    describe 'DELETE #destroy' do
      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        delete :destroy, params: { id: post.id }

        expect(thread.posts).to be_empty
        expect(response).to redirect_to(forums_thread_path(thread))
      end
    end
  end
end
