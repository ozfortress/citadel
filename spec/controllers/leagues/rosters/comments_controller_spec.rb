require 'rails_helper'

describe Leagues::Rosters::CommentsController do
  let(:user) { create(:user) }
  let(:roster) { create(:league_roster) }

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      user.grant(:edit, roster.league)
      sign_in user

      post :create, params: {
        league_id: roster.league.id, roster_id: roster.id, comment: { content: 'Foo' }
      }

      expect(roster.comments.size).to eq(1)
      comment = roster.comments.first
      expect(comment.created_by).to eq(user)
      expect(comment.roster).to eq(roster)
      expect(comment.content).to eq('Foo')
    end

    it 'fails for unauthorized user' do
      user.grant(:edit, roster.team)
      sign_in user

      post :create, params: {
        league_id: roster.league.id, roster_id: roster.id, comment: { content: 'Foo' }
      }

      expect(roster.comments).to be_empty
    end

    it 'fails for unauthenticated user' do
      post :create, params: {
        league_id: roster.league.id, roster_id: roster.id, comment: { content: 'Foo' }
      }

      expect(roster.comments).to be_empty
    end
  end

  context 'existing comment' do
    let(:comment) { create(:league_roster_comment, roster: roster, created_by: user, content: 'Foo') }

    describe 'GET #edit' do
      it 'succeeds for authorized user' do
        user.grant(:edit, roster.league)
        sign_in user

        get :edit, params: { roster_id: roster.id, id: comment.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH update' do
      it 'succeeds for authorized user' do
        user.grant(:edit, roster.league)
        sign_in user

        patch :update, params: { roster_id: roster.id, id: comment.id, comment: { content: 'Bar' } }

        comment.reload
        expect(comment.content).to eq('Bar')
        expect(comment.edits.count).to eq(1)
        expect(comment.edits.first.content).to eq('Bar')
        expect(response).to redirect_to(edit_roster_path(roster))
      end

      # TODO: Tests for unauthorized
    end

    describe 'GET #edits' do
      it 'succeeds for authorized user' do
        user.grant(:edit, roster.league)
        sign_in user

        create_list(:league_roster_comment_edit, 4, comment: comment, created_by: user)

        get :edits, params: { roster_id: roster.id, id: comment.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'DELETE destroy' do
      it 'succeeds for authorized user' do
        user.grant(:edit, roster.league)
        sign_in user

        delete :destroy, params: { roster_id: roster.id, id: comment.id }

        comment.reload
        expect(comment.deleted_by).to eq(user)
        # expect(comment.deleted_at) # TODO: Test this
        expect(response).to redirect_to(edit_roster_path(roster))
      end

      # TODO: Tests for unauthorized
    end

    describe 'PATCH restore' do
      it 'succeeds for authorized user' do
        user.grant(:edit, roster.league)
        sign_in user

        comment.update(deleted_by: user, deleted_at: Time.zone.now)

        patch :restore, params: { roster_id: roster.id, id: comment.id }

        comment.reload
        expect(comment.deleted_by).to be_nil
        expect(comment.deleted_at).to_not be_nil
        expect(response).to redirect_to(edit_roster_path(roster))
      end

      # TODO: Tests for unauthorized
    end
  end
end
