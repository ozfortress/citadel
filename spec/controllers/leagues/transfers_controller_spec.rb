require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe Leagues::TransfersController do
  let(:user) { create(:user) }
  let!(:comp) { create(:competition, matches_submittable: true) }
  let!(:div) { create(:division, competition: comp) }
  let(:player) { create(:user) }
  let(:roster) { create(:competition_roster, division: div) }
  let(:transfer) { create(:competition_transfer, roster: roster, user: player) }

  describe 'GET #index' do
    it 'succeeds for authorized user' do
      user.grant(:edit, comp)
      sign_in user

      get :index, league_id: comp.id

      expect(response).to have_http_status(:success)
    end

    it 'fails for unauthorized user' do
      sign_in user

      get :index, league_id: comp.id

      expect(response).to redirect_to(league_path(comp))
    end

    it 'fails for unauthenticated user' do
      get :index, league_id: comp.id

      expect(response).to redirect_to(league_path(comp))
    end
  end

  describe 'PATCH #update' do
    it 'succeeds for authorized user' do
      user.grant(:edit, comp)
      sign_in user

      patch :update, league_id: comp.id, id: transfer.id

      expect(roster.on_roster?(player)).to be(true)
      expect(comp.pending_transfer?(player)).to be(false)
    end

    it 'fails for unauthorized user' do
      sign_in user

      patch :update, league_id: comp.id, id: transfer.id

      expect(roster.on_roster?(player)).to be(false)
      expect(comp.pending_transfer?(player)).to be(true)
    end
  end

  describe 'DELETE #destroy' do
    it 'succeeds for authorized user' do
      user.grant(:edit, comp)
      sign_in user

      delete :destroy, league_id: comp.id, id: transfer.id

      expect(roster.on_roster?(player)).to be(false)
      expect(comp.pending_transfer?(player)).to be(false)
    end

    it 'fails for unauthorized user' do
      sign_in user

      delete :destroy, league_id: comp.id, id: transfer.id

      expect(roster.on_roster?(player)).to be(false)
      expect(comp.pending_transfer?(player)).to be(true)
    end
  end
end
