require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe Leagues::Rosters::TransfersController do
  let(:user) { create(:user) }
  let(:player) { create(:user) }
  let(:bencher) { create(:user) }
  let(:roster) { create(:competition_roster) }

  before do
    roster.team.add_player!(bencher)
    roster.team.add_player!(player)
    roster.add_player!(player)
  end

  describe 'GET #show' do
    it 'succeeds for authorized captain' do
      user.grant(:edit, roster.team)
      sign_in user

      get :show, league_id: roster.competition, roster_id: roster.id

      expect(response).to have_http_status(:success)
    end

    it 'succeeds for authorized admin' do
      user.grant(:edit, roster.competition)
      sign_in user

      get :show, league_id: roster.competition, roster_id: roster.id

      expect(response).to have_http_status(:success)
    end

    it 'redirects for unauthorized user' do
      sign_in user

      get :show, league_id: roster.competition, roster_id: roster.id

      expect(response).to redirect_to(league_roster_path(roster.competition, roster))
    end
  end

  describe 'POST #create' do
    it 'succeeds for authorized captain with bencher no auto-approve' do
      user.grant(:edit, roster.team)
      sign_in user

      post :create, league_id: roster.competition.id, roster_id: roster.id,
                    competition_transfer: { user_id: bencher.id, is_joining: true }

      expect(roster.on_roster?(bencher)).to be(false)
      expect(roster.competition.pending_transfer?(bencher)).to be(true)
    end

    it 'succeeds for authorized captain with bencher auto-approved' do
      user.grant(:edit, roster.team)
      roster.competition.update!(transfers_require_approval: false)
      sign_in user

      post :create, league_id: roster.competition.id, roster_id: roster.id,
                    competition_transfer: { user_id: bencher.id, is_joining: true }

      expect(roster.on_roster?(bencher)).to be(true)
      expect(roster.competition.pending_transfer?(bencher)).to be(false)
    end

    it 'fails transferring bencher out for authorized captain' do
      user.grant(:edit, roster.team)
      sign_in user

      post :create, league_id: roster.competition.id, roster_id: roster.id,
                    competition_transfer: { user_id: bencher.id, is_joining: false }

      expect(roster.on_roster?(bencher)).to be(false)
      expect(roster.competition.pending_transfer?(bencher)).to be(false)
    end

    # TODO: player tests, as opposed to bencher
  end
end
