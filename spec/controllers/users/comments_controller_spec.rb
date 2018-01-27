require 'rails_helper'

describe Users::CommentsController do
  let(:user) { create(:user) }
  let(:author) { create(:user) }

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      author.grant(:edit, :users)
      sign_in author

      post :create, params: { user_id: user.id, comment: { content: 'Foo' } }

      expect(user.comments.size).to eq(1)
      comment = user.comments.first
      expect(comment.user).to eq(user)
      expect(comment.created_by).to eq(author)
      expect(comment.content).to eq('Foo')
      expect(response).to redirect_to(user_path(user))
    end

    it 'fails for unauthorized user' do
      sign_in author

      post :create, params: { user_id: user.id, comment: { content: 'Foo' } }

      expect(user.comments).to be_empty
    end

    it 'fails for unauthenticated user' do
      post :create, params: { user_id: user.id, comment: { content: 'Foo' } }

      expect(user.comments).to be_empty
    end
  end

  context 'existing comment' do
    let(:comment) { create(:user_comment, user: user, created_by: author, content: 'Foo') }

    describe 'GET #edit' do
      it 'succeeds for authorized user' do
        author.grant(:edit, :users)
        sign_in author

        get :edit, params: { user_id: user.id, id: comment.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH update' do
      it 'succeeds for authorized user' do
        author.grant(:edit, :users)
        sign_in author

        patch :update, params: { user_id: user.id, id: comment.id, comment: { content: 'Bar' } }

        comment.reload
        expect(comment.content).to eq('Bar')
        expect(comment.edits.count).to eq(1)
        expect(comment.edits.first.content).to eq('Bar')
        expect(response).to redirect_to(user_path(user))
      end

      # TODO: Tests for unauthorized
    end

    describe 'GET #edits' do
      it 'succeeds for authorized user' do
        author.grant(:edit, :users)
        sign_in author

        create_list(:user_comment_edit, 4, comment: comment, created_by: author)

        get :edits, params: { user_id: user.id, id: comment.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'DELETE destroy' do
      it 'succeeds for authorized user' do
        author.grant(:edit, :users)
        sign_in author

        delete :destroy, params: { user_id: user.id, id: comment.id }

        comment.reload
        expect(comment.deleted_by).to eq(author)
        # expect(comment.deleted_at) # TODO: Test this
        expect(response).to redirect_to(user_path(user))
      end

      # TODO: Tests for unauthorized
    end

    describe 'PATCH restore' do
      it 'succeeds for authorized user' do
        author.grant(:edit, :users)
        sign_in author

        comment.update(deleted_by: author, deleted_at: Time.zone.now)

        patch :restore, params: { user_id: user.id, id: comment.id }

        comment.reload
        expect(comment.deleted_by).to be_nil
        expect(comment.deleted_at).to_not be_nil
        expect(response).to redirect_to(user_path(user))
      end

      # TODO: Tests for unauthorized
    end
  end
end
