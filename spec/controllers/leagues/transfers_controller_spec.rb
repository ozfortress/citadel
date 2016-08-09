require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe Leagues::TransfersController do
  let(:user) { create(:user) }
  let!(:league) { create(:league, matches_submittable: true) }
  let!(:div) { create(:league_division, league: league) }
  let(:player) { create(:user) }
  let(:roster) { create(:league_roster, division: div) }
  let(:transfer) { create(:league_roster_transfer, roster: roster, user: player) }

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

      patch :update, params: { league_id: league.id, id: transfer.id }

      expect(roster.on_roster?(player)).to be(true)
      expect(league.pending_transfer?(player)).to be(false)
    end

    it 'fails for unauthorized user' do
      sign_in user

      patch :update, params: { league_id: league.id, id: transfer.id }

      expect(roster.on_roster?(player)).to be(false)
      expect(league.pending_transfer?(player)).to be(true)
    end
  end

  describe 'DELETE #destroy' do
    it 'succeeds for authorized user' do
      user.grant(:edit, league)
      sign_in user

      delete :destroy, params: { league_id: league.id, id: transfer.id }

      expect(roster.on_roster?(player)).to be(false)
      expect(league.pending_transfer?(player)).to be(false)
    end

    it 'fails for unauthorized user' do
      sign_in user

      delete :destroy, params: { league_id: league.id, id: transfer.id }

      expect(roster.on_roster?(player)).to be(false)
      expect(league.pending_transfer?(player)).to be(true)
    end
  end
end
