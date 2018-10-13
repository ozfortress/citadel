require 'rails_helper'

describe Leagues::Rosters::TransfersController do
  let(:user) { create(:user) }
  let(:player) { create(:user) }
  let(:bencher) { create(:user) }
  let!(:team) { create(:team) }
  let!(:roster) { create(:league_roster, team: team) }

  before do
    team.add_player!(bencher)
    team.add_player!(player)
    roster.add_player!(player)
  end

  describe 'POST #create' do
    it 'succeeds for authorized captain with bencher not auto-approved' do
      user.grant(:edit, team)
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
      user.grant(:edit, team)
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
      user.grant(:edit, team)
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
      user.grant(:edit, team)
      sign_in user

      post :create, params: {
        league_id: roster.league.id, roster_id: roster.id,
        request: { user_id: bencher.id, is_joining: false }
      }

      expect(roster.on_roster?(bencher)).to be(false)
      expect(roster.league.transfer_requests.where(user: bencher)).to_not exist
    end

    it 'fails transferring banned bencher' do
      user.grant(:edit, team)
      sign_in user
      bencher.ban(:use, :leagues)

      post :create, params: {
        league_id: roster.league.id, roster_id: roster.id,
        request: { user_id: bencher.id, is_joining: true }
      }

      expect(roster.on_roster?(bencher)).to be(false)
      expect(roster.league.transfer_requests.where(user: bencher)).to_not exist
      expect(response).to redirect_to(edit_roster_path(roster))
    end

    it 'redirects for banned captain for leagues' do
      user.grant(:edit, team)
      user.ban(:use, :leagues)
      sign_in user

      post :create, params: {
        league_id: roster.league.id, roster_id: roster.id,
        request: { user_id: bencher.id, is_joining: true }
      }

      roster.reload
      team.reload
      expect(roster.team).to eq(team)
      expect(roster.on_roster?(bencher)).to be(false)
      expect(roster.league.transfer_requests.where(user: bencher)).to_not exist
      expect(response).to redirect_to(team_path(team))
    end

    it 'redirects for banned captain for teams' do
      user.grant(:edit, team)
      user.ban(:use, :teams)
      sign_in user

      post :create, params: {
        league_id: roster.league.id, roster_id: roster.id,
        request: { user_id: bencher.id, is_joining: true }
      }

      expect(roster.on_roster?(bencher)).to be(false)
      expect(roster.league.transfer_requests.where(user: bencher)).to_not exist
      expect(response).to redirect_to(team_path(team))
    end

    # TODO: player tests, as opposed to bencher
  end

  describe 'DELETE #destroy' do
    context 'transfer out' do
      let(:transfer_request) do
        create(:league_roster_transfer_request, roster: roster, user: player, is_joining: false)
      end

      it 'succeeds for authorized captain' do
        user.grant(:edit, team)
        sign_in user

        delete :destroy, params: { roster_id: roster.id, id: transfer_request.id }

        expect(roster.on_roster?(player)).to be(true)
        expect(roster.league.transfer_requests.where(user: player)).to_not exist
        expect(response).to redirect_to(edit_roster_path(roster))
      end

      it 'succeeds for authorized admin' do
        user.grant(:edit, roster.league)
        sign_in user

        delete :destroy, params: { roster_id: roster.id, id: transfer_request.id }

        expect(roster.on_roster?(player)).to be(true)
        expect(roster.league.transfer_requests.where(user: player)).to_not exist
        expect(response).to redirect_to(edit_roster_path(roster))
      end

      it 'fails for unauthorized user' do
        sign_in user

        delete :destroy, params: { roster_id: roster.id, id: transfer_request.id }

        expect(roster.on_roster?(player)).to be(true)
        expect(roster.league.transfer_requests.where(user: player)).to exist
        expect(response).to redirect_to(team_path(team))
      end
    end

    context 'transfer in' do
      let(:transfer_request) { create(:league_roster_transfer_request, roster: roster, user: bencher) }

      it 'succeeds for authorized captain' do
        user.grant(:edit, team)
        sign_in user

        delete :destroy, params: { roster_id: roster.id, id: transfer_request.id }

        expect(roster.on_roster?(bencher)).to be(false)
        expect(roster.league.transfer_requests.where(user: bencher)).to_not exist
        expect(response).to redirect_to(edit_roster_path(roster))
      end

      it 'succeeds for authorized admin' do
        user.grant(:edit, roster.league)
        sign_in user

        delete :destroy, params: { roster_id: roster.id, id: transfer_request.id }

        expect(roster.on_roster?(bencher)).to be(false)
        expect(roster.league.transfer_requests.where(user: bencher)).to_not exist
        expect(response).to redirect_to(edit_roster_path(roster))
      end

      it 'fails for unauthorized user' do
        sign_in user

        delete :destroy, params: { roster_id: roster.id, id: transfer_request.id }

        expect(roster.on_roster?(bencher)).to be(false)
        expect(roster.league.transfer_requests.where(user: bencher)).to exist
        expect(response).to redirect_to(team_path(team))
      end
    end
  end
end
