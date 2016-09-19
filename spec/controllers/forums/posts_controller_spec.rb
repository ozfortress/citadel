require 'rails_helper'

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

    it 'succeeds for any user' do
      sign_in user

      post :create, params: { thread_id: thread.id, forums_post: { content: 'Foo' } }

      expect(thread.posts).to_not be_empty
      post = thread.posts.first
      expect(post.content).to eq('Foo')
      expect(post.created_by).to eq(user)
    end

    it 'fails with invalid data' do
      sign_in user

      post :create, params: { thread_id: thread.id, forums_post: { content: '' } }

      expect(thread.posts).to be_empty
    end

    it 'redirects for unauthenticated user' do
      post :create, params: { thread_id: thread.id, forums_post: { content: 'Foo' } }

      expect(response).to redirect_to(forums_path)
    end

    context 'locked thread' do
      before do
        thread.update!(locked: true)
      end

      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        post :create, params: { thread_id: thread.id, forums_post: { content: 'Foo' } }

        expect(thread.posts).to_not be_empty
        post = thread.posts.first
        expect(post.content).to eq('Foo')
        expect(post.created_by).to eq(user)
      end

      it 'redirects for any user' do
        sign_in user

        post :create, params: { thread_id: thread.id, forums_post: { content: 'Foo' } }

        expect(response).to redirect_to(forums_path)
      end
    end

    context 'hidden thread' do
      before do
        thread.update!(created_by: user, hidden: true)
      end

      it 'succeeds for user who created the thread' do
        sign_in user

        post :create, params: { thread_id: thread.id, forums_post: { content: 'Foo' } }

        expect(thread.posts).to_not be_empty
        post = thread.posts.first
        expect(post.content).to eq('Foo')
        expect(post.created_by).to eq(user)
      end

      it 'redirects for other users' do
        sign_in create(:user)

        post :create, params: { thread_id: thread.id, forums_post: { content: 'Foo' } }

        expect(response).to redirect_to(forums_path)
      end
    end
  end

  context 'Existing Post' do
    let!(:post) { create(:forums_post, thread: thread, content: 'Foo') }

    describe 'GET #edits' do
      it 'succeeds for any user' do
        create_list(:forums_post_edit, 3, post: post)
        sign_in user

        get :edits, params: { id: post.id }

        expect(response).to have_http_status(:success)
      end
    end

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

      it 'succeeds for user who created the post' do
        post.update!(created_by: user)
        sign_in user

        patch :update, params: { id: post.id, forums_post: { content: 'Test' } }

        post.reload
        expect(post.content).to eq('Test')
        expect(response).to redirect_to(forums_thread_path(thread))
      end

      it 'fails for invalid data' do
        user.grant(:manage, :forums)
        sign_in user

        patch :update, params: { id: post.id, forums_post: { content: '' } }

        post.reload
        expect(post.content).to eq('Foo')
      end

      it 'redirects for any user' do
        sign_in user

        patch :update, params: { id: post.id, forums_post: { content: 'Test' } }

        expect(response).to redirect_to(forums_path)
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

      it 'redirects for any user' do
        post.update!(created_by: user)
        sign_in user

        delete :destroy, params: { id: post.id }

        expect(thread.posts).to_not be_empty
        expect(response).to redirect_to(forums_path)
      end
    end
  end
end
