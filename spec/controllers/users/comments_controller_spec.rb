require 'rails_helper'

describe Users::CommentsController do
  let(:user) { create(:user) }
  let(:author) { create(:user) }

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      author.grant(:edit, :users)
      sign_in author

      post :create, params: {
        user_id: user.id, comment: { content: 'Foo' }
      }

      expect(user.comments.size).to eq(1)
      comment = user.comments.first
      expect(comment.user).to eq(user)
      expect(comment.created_by).to eq(author)
      expect(comment.content).to eq('Foo')
    end

    it 'fails for unauthorized user' do
      sign_in author

      post :create, params: {
        user_id: user.id, comment: { content: 'Foo' }
      }

      expect(user.comments).to be_empty
    end

    it 'fails for unauthenticated user' do
      post :create, params: {
        user_id: user.id, comment: { content: 'Foo' }
      }

      expect(user.comments).to be_empty
    end
  end
end
