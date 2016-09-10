require 'rails_helper'

describe Leagues::Matches::CommsController do
  let(:user) { create(:user) }
  let(:match) { create(:league_match) }

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      user.grant(:edit, match.home_team.team)
      sign_in user

      post :create, params: { league_id: match.league.id, match_id: match.id, comm: { content: 'A' } }

      comm = match.comms.first
      expect(comm).to_not be nil
      expect(comm.match).to eq(match)
      expect(comm.content).to eq('A')
    end

    it 'fails with invalid data' do
      user.grant(:edit, match.home_team.team)
      sign_in user

      post :create, params: { league_id: match.league.id, match_id: match.id, comm: { content: nil } }

      expect(match.comms.first).to be(nil)
    end

    it 'fails for unauthorized user' do
      sign_in user

      post :create, params: { league_id: match.league.id, match_id: match.id, comm: { content: 'A' } }

      expect(match.comms.first).to be(nil)
    end
  end
end
