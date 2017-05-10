require 'rails_helper'

describe Forums::PostsController do
  let(:topic) { create(:forums_topic) }
  let(:thread) { create(:forums_thread, topic: topic) }
  let(:user) { create(:user) }
  let(:content) { 'ABCDEFGHIJKLMNOP' }

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      user.grant(:manage, :forums)
      sign_in user

      post :create, params: { thread_id: thread.id, forums_post: { content: content } }

      thread.reload
      expect(thread.posts).to_not be_empty
      post = thread.posts.first
      expect(post.content).to eq(content)
      expect(post.created_by).to eq(user)
    end

    it 'succeeds for any user' do
      sign_in user

      post :create, params: { thread_id: thread.id, forums_post: { content: content } }

      thread.reload
      expect(thread.posts).to_not be_empty
      post = thread.posts.first
      expect(post.content).to eq(content)
      expect(post.created_by).to eq(user)
    end

    it 'fails with invalid data' do
      sign_in user

      post :create, params: { thread_id: thread.id, forums_post: { content: '' } }

      thread.reload
      expect(thread.posts).to be_empty
    end

    it 'redirects for banned user for forums' do
      user.ban(:use, :forums)
      sign_in user

      post :create, params: { thread_id: thread.id, forums_post: { content: content } }

      thread.reload
      expect(thread.posts).to be_empty
      expect(response).to redirect_to(forums_path)
    end

    it 'redirects for banned user for topic' do
      user.ban(:use, topic)
      sign_in user

      post :create, params: { thread_id: thread.id, forums_post: { content: content } }

      thread.reload
      expect(thread.posts).to be_empty
      expect(response).to redirect_to(forums_path)
    end

    it 'redirects for banned user for thread' do
      user.ban(:use, thread)
      sign_in user

      post :create, params: { thread_id: thread.id, forums_post: { content: content } }

      thread.reload
      expect(thread.posts).to be_empty
      expect(response).to redirect_to(forums_path)
    end

    it 'redirects for unauthenticated user' do
      post :create, params: { thread_id: thread.id, forums_post: { content: content } }

      thread.reload
      expect(thread.posts).to be_empty
      expect(response).to redirect_to(forums_path)
    end

    context 'locked thread' do
      before do
        thread.update!(locked: true)
      end

      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        post :create, params: { thread_id: thread.id, forums_post: { content: content } }

        thread.reload
        expect(thread.posts).to_not be_empty
        post = thread.posts.first
        expect(post.content).to eq(content)
        expect(post.created_by).to eq(user)
      end

      it 'redirects for any user' do
        sign_in user

        post :create, params: { thread_id: thread.id, forums_post: { content: content } }

        expect(response).to redirect_to(forums_path)
      end
    end

    context 'hidden thread' do
      before do
        thread.update!(created_by: user, hidden: true)
      end

      it 'succeeds for user who created the thread' do
        sign_in user

        post :create, params: { thread_id: thread.id, forums_post: { content: content } }

        thread.reload
        expect(thread.posts).to_not be_empty
        post = thread.posts.first
        expect(post.content).to eq(content)
        expect(post.created_by).to eq(user)
      end

      it 'redirects for other users' do
        sign_in create(:user)

        post :create, params: { thread_id: thread.id, forums_post: { content: content } }

        expect(response).to redirect_to(forums_path)
      end
    end
  end

  context 'Existing Post' do
    let!(:post) { create(:forums_post, thread: thread, content: content) }

    describe 'GET #edits' do
      it 'redirects for any user' do
        create_list(:forums_post_edit, 3, post: post)
        sign_in user

        get :edits, params: { id: post.id }

        expect(response).to redirect_to(forums_path)
      end

      it 'succeeds for author' do
        create_list(:forums_post_edit, 3, post: post)
        sign_in post.created_by

        get :edits, params: { id: post.id }

        expect(response).to have_http_status(:success)
      end

      it 'succeeds for admin' do
        create_list(:forums_post_edit, 3, post: post)
        user.grant(:manage, :forums)
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

        patch :update, params: { id: post.id, forums_post: { content: content } }

        post.reload
        expect(post.content).to eq(content)
        path = forums_thread_path(thread, page: 1, anchor: "post_#{post.id}")
        expect(response).to redirect_to(path)
      end

      it 'succeeds for user who created the post' do
        post.update!(created_by: user)
        sign_in user

        patch :update, params: { id: post.id, forums_post: { content: content } }

        post.reload
        expect(post.content).to eq(content)
        path = forums_thread_path(thread, page: 1, anchor: "post_#{post.id}")
        expect(response).to redirect_to(path)
      end

      it 'fails for invalid data' do
        user.grant(:manage, :forums)
        sign_in user

        patch :update, params: { id: post.id, forums_post: { content: '' } }

        post.reload
        expect(post.content).to eq(content)
      end

      it 'redirects for banned author for forums' do
        post.update!(created_by: user)
        user.ban(:use, :forums)
        sign_in user

        patch :update, params: { id: post.id, forums_post: { content: content } }

        post.reload
        expect(post.content).to eq(content)
        expect(response).to redirect_to(forums_path)
      end

      it 'redirects for banned author for topic' do
        post.update!(created_by: user)
        user.ban(:use, topic)
        sign_in user

        patch :update, params: { id: post.id, forums_post: { content: content } }

        post.reload
        expect(post.content).to eq(content)
        expect(response).to redirect_to(forums_path)
      end

      it 'redirects for banned author for thread' do
        post.update!(created_by: user)
        user.ban(:use, thread)
        sign_in user

        patch :update, params: { id: post.id, forums_post: { content: content } }

        post.reload
        expect(post.content).to eq(content)
        expect(response).to redirect_to(forums_path)
      end

      it 'redirects for any user' do
        sign_in user

        patch :update, params: { id: post.id, forums_post: { content: content } }

        post.reload
        expect(post.content).to eq(content)
        expect(response).to redirect_to(forums_path)
      end
    end

    describe 'DELETE #destroy' do
      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        delete :destroy, params: { id: post.id }

        thread.reload
        expect(thread.posts).to be_empty
        expect(response).to redirect_to(forums_thread_path(thread))
      end

      it 'redirects for any user' do
        post.update!(created_by: user)
        sign_in user

        delete :destroy, params: { id: post.id }

        thread.reload
        expect(thread.posts).to_not be_empty
        expect(response).to redirect_to(forums_path)
      end
    end
  end
end
