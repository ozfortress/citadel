require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe Leagues::Rosters::CommentsController do
  let(:user) { create(:user) }
  let(:roster) { create(:competition_roster) }

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      user.grant(:edit, roster.competition)
      sign_in user

      post :create, league_id: roster.competition.id, roster_id: roster.id,
                    competition_roster_comment: { content: 'Foo' }

      expect(roster.comments.size).to eq(1)
      comment = roster.comments.first
      expect(comment.user).to eq(user)
      expect(comment.roster).to eq(roster)
      expect(comment.content).to eq('Foo')
    end

    it 'fails for unauthorized user' do
      user.grant(:edit, roster.team)
      sign_in user

      post :create, league_id: roster.competition.id, roster_id: roster.id,
                    competition_roster_comment: { content: 'Foo' }

      expect(roster.comments).to be_empty
    end

    it 'fails for unauthenticated user' do
      post :create, league_id: roster.competition.id, roster_id: roster.id,
                    competition_roster_comment: { content: 'Foo' }

      expect(roster.comments).to be_empty
    end
  end
end
