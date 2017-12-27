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
end
