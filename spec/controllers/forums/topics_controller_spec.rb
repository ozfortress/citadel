require 'rails_helper'

describe Forums::TopicsController do
  let(:parent_topic) { create(:forums_topic) }
  let(:user) { create(:user) }

  describe 'GET #new' do
    it 'succeeds for authorized user' do
      user.grant(:manage, :forums)
      sign_in user

      get :new, params: { parent: parent_topic.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      user.grant(:manage, :forums)
      sign_in user

      post :create, params: { parent: parent_topic.id, forums_topic: {
        name: 'Foo', locked: true, pinned: true, hidden: true, isolated: true,
        default_hidden: true
      } }

      expect(parent_topic.children).to_not be_empty
      topic = parent_topic.children.first
      expect(topic.name).to eq('Foo')
      expect(topic.created_by).to eq(user)
      expect(topic.locked).to eq(true)
      expect(topic.pinned).to eq(true)
      expect(topic.hidden).to eq(true)
      expect(topic.isolated).to eq(false)
      expect(topic.default_hidden).to eq(true)
      expect(response).to redirect_to(forums_topic_path(topic))
    end

    it 'succeeds in isolated forum for authorized user' do
      parent_topic.update!(isolated: true)
      user.grant(:manage, parent_topic)
      sign_in user

      post :create, params: { parent: parent_topic.id, forums_topic: {
        name: 'Foo', locked: true, pinned: true, hidden: true, isolated: true,
        default_hidden: true
      } }

      expect(parent_topic.children).to_not be_empty
      topic = parent_topic.children.first
      expect(topic.name).to eq('Foo')
      expect(topic.created_by).to eq(user)
      expect(topic.locked).to eq(true)
      expect(topic.pinned).to eq(true)
      expect(topic.hidden).to eq(true)
      expect(topic.isolated).to eq(false)
      expect(topic.default_hidden).to eq(true)
      expect(response).to redirect_to(forums_topic_path(topic))
    end

    it 'fails with invalid data' do
      user.grant(:manage, :forums)
      sign_in user

      post :create, params: { parent: parent_topic.id, forums_topic: { name: '' } }

      expect(parent_topic.children).to be_empty
    end

    it 'redirects for unauthorized user in isolated forum' do
      parent_topic.update!(isolated: true)
      user.grant(:manage, :forums)
      sign_in user

      post :create, params: { parent: parent_topic.id, forums_topic: { name: 'Foo' } }

      expect(response).to redirect_to(forums_path)
    end

    it 'redirects for unauthorized user' do
      sign_in user

      post :create, params: { parent: parent_topic.id, forums_topic: { name: 'Foo' } }

      expect(response).to redirect_to(forums_path)
    end

    it 'redirects for unauthenticated user' do
      post :create, params: { parent: parent_topic.id, forums_topic: { name: 'Foo' } }

      expect(response).to redirect_to(forums_path)
    end
  end

  context 'Existing Topic' do
    let(:topic) { create(:forums_topic, parent: parent_topic, name: 'Foo') }

    describe 'GET #show' do
      it 'succeeds' do
        get :show, params: { id: topic.id }

        expect(response).to have_http_status(:success)
      end

      context 'hidden topic' do
        before do
          topic.update!(hidden: true)
        end

        it 'succeeds for authorized user' do
          user.grant(:manage, topic)
          sign_in user

          get :show, params: { id: topic.id }

          expect(response).to have_http_status(:success)
        end

        it 'redirects for unauthorized user' do
          sign_in user

          get :show, params: { id: topic.id }

          expect(response).to redirect_to(forums_path)
        end

        it 'redirects for unauthenticated user' do
          get :show, params: { id: topic.id }

          expect(response).to redirect_to(forums_path)
        end
      end
    end

    describe 'PATCH #toggle_subscription' do
      it 'subscribes unsubscribed user' do
        sign_in user

        patch :toggle_subscription, params: { id: topic.id }

        expect(user.forums_subscriptions.where(topic: topic)).to exist
        expect(response).to redirect_to(forums_topic_path(topic))
      end

      it 'subsubscribes subscribed user' do
        sign_in user
        user.forums_subscriptions.create(topic: topic)

        patch :toggle_subscription, params: { id: topic.id }

        expect(user.forums_subscriptions.where(topic: topic)).to_not exist
        expect(response).to redirect_to(forums_topic_path(topic))
      end

      it 'redirects for unauthorized user' do
        sign_in user
        topic.update!(hidden: true)

        patch :toggle_subscription, params: { id: topic.id }

        expect(response).to redirect_to(forums_path)
      end

      it 'redirects for unauthenticated user' do
        patch :toggle_subscription, params: { id: topic.id }

        expect(response).to redirect_to(root_path)
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

        patch :update, params: {
          id:           topic.id,
          forums_topic: {
            name: 'Test', locked: true, pinned: true, hidden: true, isolated: true,
            default_hidden: true
          },
        }

        topic.reload
        expect(topic.name).to eq('Test')
        expect(topic.locked).to eq(true)
        expect(topic.pinned).to eq(true)
        expect(topic.hidden).to eq(true)
        expect(topic.isolated).to eq(false)
        expect(topic.default_hidden).to eq(true)
        expect(response).to redirect_to(forums_topic_path(topic))
      end

      it 'fails with invalid data' do
        user.grant(:manage, :forums)
        sign_in user

        patch :update, params: { id: topic.id, forums_topic: { name: '' } }

        topic.reload
        expect(topic.name).to eq('Foo')
      end

      context 'isolated forum' do
        before do
          parent_topic.update!(isolated: true)
        end

        it 'succeeds for authorized user' do
          user.grant(:manage, parent_topic)
          sign_in user

          patch :update, params: { id: topic.id, forums_topic: { name: 'Test' } }

          topic.reload
          expect(topic.name).to eq('Test')
          expect(response).to redirect_to(forums_topic_path(topic))
        end

        it 'redirects for unauthorized user' do
          user.grant(:manage, :forums)
          sign_in user

          patch :update, params: { id: topic.id, forums_topic: { name: 'Test' } }

          expect(response).to redirect_to(forums_path)
        end
      end
    end

    describe 'PATCH #isolate' do
      let(:user2) { create(:user) }

      it 'succeeds for authorized user' do
        user.grant(:manage, :forums)
        sign_in user
        user2.grant(:manage, :forums)

        patch :isolate, params: { id: topic.id }

        topic.reload
        expect(topic.isolated?).to be(true)
        expect(user.can?(:manage, topic)).to be(true)
        expect(user2.can?(:manage, topic)).to be(false)
        expect(response).to redirect_to(forums_topic_path(topic))
      end

      it 'redirects for unauthorized user' do
        sign_in user

        patch :isolate, params: { id: topic.id }

        topic.reload
        expect(topic.isolated?).to be(false)
        expect(user.can?(:manage, topic)).to be(false)
        expect(response).to redirect_to(forums_path)
      end
    end

    describe 'PATH #unisolate' do
      let(:user2) { create(:user) }

      it 'succeeds for authorized user' do
        user.grant(:manage, topic)
        sign_in user
        topic.update(isolated: true)

        patch :unisolate, params: { id: topic.id }

        topic.reload
        expect(topic.isolated?).to be(false)
        expect(user.can?(:manage, topic)).to be(true)
        expect(response).to redirect_to(forums_topic_path(topic))
      end

      it 'redirects for unauthorized user' do
        user.grant(:manage, :forums)
        sign_in user
        topic.update(isolated: true)

        patch :unisolate, params: { id: topic.id }

        topic.reload
        expect(topic.isolated?).to be(true)
        expect(user.can?(:manage, topic)).to be(false)
        expect(response).to redirect_to(forums_path)
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

      context 'isolated forum' do
        before do
          parent_topic.update!(isolated: true)
        end

        it 'succeeds for authorized user' do
          user.grant(:manage, parent_topic)
          sign_in user

          delete :destroy, params: { id: topic.id }

          expect(topic.children).to be_empty
          expect(response).to redirect_to(forums_topic_path(parent_topic))
        end

        it 'redirects for unauthorized user' do
          user.grant(:manage, :forums)
          sign_in user

          delete :destroy, params: { id: topic.id }

          expect(response).to redirect_to(forums_path)
        end
      end
    end
  end
end
