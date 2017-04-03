require 'rails_helper'

describe Leagues::TransfersController do
  let(:user) { create(:user) }
  let!(:league) { create(:league, matches_submittable: true) }
  let!(:div) { create(:league_division, league: league) }
  let(:player) { create(:user) }
  let(:captain) { create(:user) }
  let(:roster) { create(:league_roster, division: div) }
  let(:transfer_request) do
    create(:league_roster_transfer_request, propagate: true, roster: roster, user: player)
  end

  before do
    captain.grant(:edit, roster.team)
  end

  describe 'GET #index' do
    it 'succeeds for authorized user' do
      user.grant(:edit, league)
      sign_in user

      get :index, params: { league_id: league.id }

      expect(response).to have_http_status(:success)
    end

    it 'fails for unauthorized user' do
      sign_in user

      get :index, params: { league_id: league.id }

      expect(response).to redirect_to(league_path(league))
    end

    it 'fails for unauthenticated user' do
      get :index, params: { league_id: league.id }

      expect(response).to redirect_to(league_path(league))
    end
  end

  describe 'PATCH #update' do
    it 'succeeds for authorized user' do
      user.grant(:edit, league)
      sign_in user

      patch :update, params: { league_id: league.id, id: transfer_request.id }

      expect(roster.on_roster?(player)).to be(true)
      expect(league.transfer_requests.find_by(user: player)).to be_approved
      expect(captain.notifications).to_not be_empty
      expect(transfer_request.user.notifications).to_not be_empty
    end

    it 'fails for unauthorized user' do
      sign_in user

      patch :update, params: { league_id: league.id, id: transfer_request.id }

      expect(roster.on_roster?(player)).to be(false)
      expect(league.transfer_requests.find_by(user: player)).to be_pending
    end
  end

  describe 'DELETE #destroy' do
    it 'succeeds for authorized user' do
      user.grant(:edit, league)
      sign_in user

      delete :destroy, params: { league_id: league.id, id: transfer_request.id }

      expect(roster.on_roster?(player)).to be(false)
      expect(league.transfer_requests.find_by(user: player)).to be_denied
      expect(captain.notifications).to_not be_empty
      expect(transfer_request.user.notifications).to_not be_empty
    end

    it 'fails for unauthorized user' do
      sign_in user

      delete :destroy, params: { league_id: league.id, id: transfer_request.id }

      expect(roster.on_roster?(player)).to be(false)
      expect(league.transfer_requests.where(user: player)).to exist
    end
  end
end
