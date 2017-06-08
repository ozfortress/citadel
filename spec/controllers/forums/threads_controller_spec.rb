require 'rails_helper'

describe Forums::ThreadsController do
  let(:topic) { create(:forums_topic) }
  let(:user) { create(:user) }
  let(:content) { 'ABCDEFGHIJKLMNOP' }

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

      post :create, params: {
        topic: topic.id,
        forums_thread: {
          title: 'Foo', locked: true, pinned: true, hidden: true,
          forums_post: { content: content }
        }
      }

      topic.reload
      expect(topic.threads).to_not be_empty
      thread = topic.threads.first
      expect(thread.title).to eq('Foo')
      expect(thread.created_by).to eq(user)
      expect(thread.locked).to eq(true)
      expect(thread.pinned).to eq(true)
      expect(thread.hidden).to eq(true)
      expect(thread.posts).to_not be_empty
      post = thread.posts.first
      expect(post.content).to eq(content)
      expect(post.created_by).to eq(user)
      expect(response).to redirect_to(forums_thread_path(thread))
    end

    it 'fails with invalid data' do
      user.grant(:manage, :forums)
      sign_in user

      post :create, params: {
        topic: topic.id,
        forums_thread: {
          title: '', forums_post: { content: '' }
        }
      }

      topic.reload
      expect(topic.threads).to be_empty
    end

    it 'succeeds for any user' do
      sign_in user

      post :create, params: {
        topic: topic.id,
        forums_thread: {
          title: 'Foo', locked: true, pinned: true, hidden: true,
          forums_post: { content: content }
        }
      }

      topic.reload
      expect(topic.threads).to_not be_empty
      thread = topic.threads.first
      expect(thread.title).to eq('Foo')
      expect(thread.created_by).to eq(user)
      expect(thread.locked).to eq(false)
      expect(thread.pinned).to eq(false)
      expect(thread.hidden).to eq(false)
      expect(thread.posts).to_not be_empty
      post = thread.posts.first
      expect(post.content).to eq(content)
      expect(post.created_by).to eq(user)
      expect(response).to redirect_to(forums_thread_path(thread))
    end

    it 'redirects for banned user' do
      user.ban(:use, topic)
      sign_in user

      post :create, params: {
        topic: topic.id,
        forums_thread: {
          title: 'Foo', locked: true, pinned: true, hidden: true,
          forums_post: { content: content }
        }
      }

      topic.reload
      expect(topic.threads).to be_empty
      expect(response).to redirect_to(forums_path)
    end

    it 'redirects for unauthenticated user' do
      post :create, params: { topic: topic.id, forums_thread: { title: 'Foo' } }

      expect(response).to redirect_to(forums_path)
    end

    context 'root thread' do
      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        post :create, params: {
          forums_thread: {
            title: 'Foo', locked: true, pinned: true, hidden: true,
            forums_post: { content: content }
          }
        }

        expect(Forums::Thread.all).to_not be_empty
        thread = Forums::Thread.first
        expect(thread.title).to eq('Foo')
        expect(thread.created_by).to eq(user)
        expect(thread.locked).to eq(true)
        expect(thread.pinned).to eq(true)
        expect(thread.hidden).to eq(true)
        expect(response).to redirect_to(forums_thread_path(thread))
      end

      it 'redirects for banned user' do
        user.ban(:use, :forums)
        sign_in user

        post :create, params: {
          forums_thread: {
            title: 'Foo', locked: true, pinned: true, hidden: true,
            forums_post: { content: content }
          }
        }

        expect(Forums::Thread.all).to be_empty
        expect(response).to redirect_to(forums_path)
      end

      it 'redirects for any user' do
        sign_in user

        post :create, params: { forums_thread: { title: 'Foo' } }

        expect(Forums::Thread.all).to be_empty
        expect(response).to redirect_to(forums_path)
      end
    end

    context 'default hidden' do
      before do
        topic.update!(default_hidden: true)
      end

      it 'creates hidden threads for any user' do
        sign_in user

        post :create, params: {
          topic: topic.id, forums_thread: {
            title: 'Foo', hidden: false, forums_post: { content: content }
          }
        }

        topic.reload
        expect(topic.threads).to_not be_empty
        thread = topic.threads.first
        expect(thread.title).to eq('Foo')
        expect(thread.created_by).to eq(user)
        expect(thread.hidden).to eq(true)
        expect(response).to redirect_to(forums_thread_path(thread))
      end
    end

    context 'locked topic' do
      before do
        topic.update!(locked: true)
      end

      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        post :create, params: {
          topic: topic.id, forums_thread: { title: 'Foo', forums_post: { content: content } }
        }

        topic.reload
        expect(topic.threads).to_not be_empty
        thread = topic.threads.first
        expect(response).to redirect_to(forums_thread_path(thread))
      end

      it 'redirects for any user' do
        sign_in user

        post :create, params: { topic: topic.id, forums_thread: { title: 'Foo' } }

        topic.reload
        expect(topic.threads).to be_empty
        expect(response).to redirect_to(forums_path)
      end
    end

    context 'hidden topic' do
      before do
        topic.update!(hidden: true)
      end

      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        post :create, params: {
          topic: topic.id, forums_thread: { title: 'Foo', forums_post: { content: content } }
        }

        topic.reload
        expect(topic.threads).to_not be_empty
        thread = topic.threads.first
        expect(response).to redirect_to(forums_thread_path(thread))
      end

      it 'redirects for any user' do
        sign_in user

        post :create, params: { topic: topic.id, forums_thread: { title: 'Foo' } }

        topic.reload
        expect(topic.threads).to be_empty
        expect(response).to redirect_to(forums_path)
      end
    end

    context 'isolated topic' do
      before do
        topic.update!(isolated: true)
      end

      it 'succeeds for any user' do
        user.grant(:manage, :forums)
        sign_in user

        post :create, params: {
          topic: topic.id,
          forums_thread: {
            title: 'Foo', locked: true, pinned: true, hidden: true,
            forums_post: { content: content }
          }
        }

        topic.reload
        expect(topic.threads).to_not be_empty
        thread = topic.threads.first
        expect(thread.title).to eq('Foo')
        expect(thread.created_by).to eq(user)
        expect(thread.locked).to eq(false)
        expect(thread.pinned).to eq(false)
        expect(thread.hidden).to eq(false)
        expect(response).to redirect_to(forums_thread_path(thread))
      end
    end
  end

  context 'Existing Thread' do
    let(:thread) { create(:forums_thread, topic: topic) }

    before do
      create(:forums_post, thread: thread)
    end

    describe 'GET #show' do
      it 'succeeds' do
        get :show, params: { id: thread.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH #toggle_subscription' do
      it 'subscribes unsubscribed user' do
        sign_in user

        patch :toggle_subscription, params: { id: thread.id }

        expect(user.forums_subscriptions.where(thread: thread)).to exist
        expect(response).to redirect_to(forums_thread_path(thread))
      end

      it 'subsubscribes subscribed user' do
        sign_in user
        user.forums_subscriptions.create(thread: thread)

        patch :toggle_subscription, params: { id: thread.id }

        expect(user.forums_subscriptions.where(thread: thread)).to_not exist
        expect(response).to redirect_to(forums_thread_path(thread))
      end

      it 'redirects for unauthorized user' do
        sign_in user
        thread.update!(hidden: true)

        patch :toggle_subscription, params: { id: thread.id }

        expect(response).to redirect_to(forums_path)
      end

      it 'redirects for unauthenticated user' do
        patch :toggle_subscription, params: { id: thread.id }

        expect(response).to redirect_to(root_path)
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

        patch :update, params: {
          id: thread.id, forums_thread: {
            title: 'Test', locked: true, pinned: true, hidden: true,
            forums_post: { content: content },
          }
        }

        thread.reload
        expect(thread.title).to eq('Test')
        expect(thread.locked).to be(true)
        expect(thread.pinned).to be(true)
        expect(thread.hidden).to be(true)
        expect(thread.posts.first.content).to eq(content)
        expect(response).to redirect_to(forums_thread_path(thread))
      end

      it 'succeeds for creator' do
        thread.update!(created_by: user)
        sign_in user

        patch :update, params: {
          id: thread.id, forums_thread: {
            title: 'Test', locked: true, pinned: true, hidden: true,
            forums_post: { content: content },
          }
        }

        thread.reload
        expect(thread.title).to eq('Test')
        expect(thread.locked).to be(false)
        expect(thread.pinned).to be(false)
        expect(thread.hidden).to be(false)
        expect(thread.posts.first.content).to eq(content)
        expect(response).to redirect_to(forums_thread_path(thread))
      end

      it 'fails for invalid thread data' do
        user.grant(:manage, :forums)
        sign_in user

        patch :update, params: {
          id: thread.id, forums_thread: {
            title: '', forums_post: { content: '' }
          }
        }

        thread.reload
        expect(thread.title).to_not eq('Test')
        expect(response).to have_http_status(:success)
      end

      it 'fails for invalid post data' do
        user.grant(:manage, :forums)
        sign_in user

        patch :update, params: {
          id: thread.id, forums_thread: {
            title: 'Test', locked: true, pinned: true, hidden: true,
            forums_post: { content: '' },
          }
        }

        thread.reload
        expect(thread.title).to_not eq('Test')
        expect(thread.posts.first.content).to_not eq('')
        expect(response).to have_http_status(:success)
      end

      it 'redirects for banned user for forums' do
        user.ban(:use, :forums)
        sign_in user

        patch :update, params: {
          id: thread.id, forums_thread: {
            title: 'Test', locked: true, pinned: true, hidden: true,
            forums_post: {},
          }
        }

        thread.reload
        expect(thread.title).to_not eq('Test')
        expect(response).to redirect_to(forums_path)
      end

      it 'redirects for banned user for topic' do
        user.ban(:use, topic)
        sign_in user

        patch :update, params: {
          id: thread.id, forums_thread: {
            title: 'Test', locked: true, pinned: true, hidden: true,
            forums_post: {},
          }
        }

        thread.reload
        expect(thread.title).to_not eq('Test')
        expect(response).to redirect_to(forums_path)
      end

      it 'redirects for banned user for thread' do
        user.ban(:use, thread)
        sign_in user

        patch :update, params: {
          id: thread.id, forums_thread: {
            title: 'Test', locked: true, pinned: true, hidden: true,
            forums_post: {},
          }
        }

        thread.reload
        expect(thread.title).to_not eq('Test')
        expect(response).to redirect_to(forums_path)
      end

      it 'redirects for any user' do
        sign_in user

        patch :update, params: {
          id: thread.id, forums_thread: { title: 'Test', forums_post: {} }
        }

        thread.reload
        expect(thread.title).to_not eq('Test')
        expect(response).to redirect_to(forums_path)
      end
    end

    describe 'DELETE #destroy' do
      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user

        delete :destroy, params: { id: thread.id }

        topic.reload
        expect(topic.threads).to be_empty
        expect(response).to redirect_to(forums_topic_path(topic))
      end

      it 'fails for any user' do
        thread.update!(created_by: user)
        sign_in user

        delete :destroy, params: { id: thread.id }

        topic.reload
        expect(topic.threads).to_not be_empty
        expect(response).to redirect_to(forums_path)
      end
    end
  end
end
