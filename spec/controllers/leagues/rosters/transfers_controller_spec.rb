require 'rails_helper'

describe Leagues::Rosters::TransfersController do
  let(:user) { create(:user) }
  let(:player) { create(:user) }
  let(:bencher) { create(:user) }
  let(:roster) { create(:league_roster) }

  before do
    roster.team.add_player!(bencher)
    roster.team.add_player!(player)
    roster.add_player!(player)
  end

  describe 'POST #create' do
    it 'succeeds for authorized captain with bencher not auto-approved' do
      user.grant(:edit, roster.team)
      sign_in user

      post :create, params: {
        league_id: roster.league.id, roster_id: roster.id,
        request: { user_id: bencher.id, is_joining: true }
      }

      expect(roster.on_roster?(bencher)).to be(false)
      expect(roster.league.transfer_requests.where(user: bencher)).to exist
      expect(user.notifications).to be_empty
      expect(bencher.notifications).to_not be_empty
    end

    it 'succeeds for authorized captain with bencher auto-approved' do
      user.grant(:edit, roster.team)
      roster.league.update!(transfers_require_approval: false)
      sign_in user

      post :create, params: {
        league_id: roster.league.id, roster_id: roster.id,
        request: { user_id: bencher.id, is_joining: true }
      }

      expect(roster.on_roster?(bencher)).to be(true)
      expect(roster.league.transfer_requests.where(user: bencher)).to_not exist
      expect(user.notifications).to be_empty
      expect(bencher.notifications).to_not be_empty
    end

    it 'fails if rosters are locked' do
      user.grant(:edit, roster.team)
      roster.league.update!(roster_locked: true)
      sign_in user

      post :create, params: {
        league_id: roster.league.id, roster_id: roster.id,
        request: { user_id: bencher.id, is_joining: true }
      }

      expect(roster.on_roster?(bencher)).to be(false)
      expect(roster.league.transfer_requests.where(user: bencher)).to_not exist
    end

    it 'fails transferring bencher out for authorized captain' do
      user.grant(:edit, roster.team)
      sign_in user

      post :create, params: {
        league_id: roster.league.id, roster_id: roster.id,
        request: { user_id: bencher.id, is_joining: false }
      }

      expect(roster.on_roster?(bencher)).to be(false)
      expect(roster.league.transfer_requests.where(user: bencher)).to_not exist
    end

    # TODO: player tests, as opposed to bencher
  end
end
