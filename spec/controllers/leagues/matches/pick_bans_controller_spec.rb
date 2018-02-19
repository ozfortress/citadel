require 'rails_helper'

describe Leagues::Matches::PickBansController do
  let(:user) { create(:user) }
  let(:pick_ban) { create(:league_match_pick_ban, kind: :pick, team: :home_team, deferrable: true) }
  let(:match) { pick_ban.match }
  let(:map) { create(:map) }

  describe 'PATCH submit' do
    it 'succeeds for authorized admin' do
      user.grant(:edit, pick_ban.league)
      sign_in user

      patch :submit, params: { id: pick_ban.id, pick_ban: { map_id: map.id } }

      expect(match.reload.rounds.length).to eq(1)
      expect(response).to redirect_to(match_path(match))
    end

    it 'succeeds for authorized captain on home_team' do
      user.grant(:edit, match.home_team.team)
      sign_in user

      patch :submit, params: { id: pick_ban.id, pick_ban: { map_id: map.id } }

      expect(match.reload.rounds.length).to eq(1)
      expect(response).to redirect_to(match_path(match))
    end

    it 'redirects for authorized captain on away_team' do
      user.grant(:edit, match.away_team.team)
      sign_in user

      patch :submit, params: { id: pick_ban.id, pick_ban: { map_id: map.id } }

      expect(match.reload.rounds).to be_empty
      expect(response).to redirect_to(match_path(match))
    end

    it 'redirects for unauthorized user' do
      sign_in user

      patch :submit, params: { id: pick_ban.id, pick_ban: { map_id: map.id } }

      expect(match.reload.rounds).to be_empty
      expect(response).to redirect_to(match_path(match))
    end

    it 'redirects for unauthenticated user' do
      patch :submit, params: { id: pick_ban.id, pick_ban: { map_id: map.id } }

      expect(match.reload.rounds).to be_empty
      expect(response).to redirect_to(match_path(match))
    end
  end

  describe 'PATCH defer' do
    it 'succeeds for authorized admin' do
      user.grant(:edit, pick_ban.league)
      sign_in user

      patch :defer, params: { id: pick_ban.id }

      match.reload
      expect(match.pick_bans.length).to eq(2)
      expect(pick_ban.reload.home_team?).to be(true)
      expect(match.pick_bans[0]).to eq(pick_ban)
      expect(match.pick_bans[1].away_team?).to be(true)
      expect(match.rounds).to be_empty
      expect(response).to redirect_to(match_path(match))
    end

    it 'succeeds for authorized captain on home_team' do
      user.grant(:edit, match.home_team.team)
      sign_in user

      patch :defer, params: { id: pick_ban.id }

      match.reload
      expect(match.pick_bans.length).to eq(2)
      expect(pick_ban.reload.home_team?).to be(true)
      expect(match.pick_bans[0]).to eq(pick_ban)
      expect(match.pick_bans[1].away_team?).to be(true)
      expect(match.rounds).to be_empty
      expect(response).to redirect_to(match_path(match))
    end

    it 'redirects for authorized captain on away_team' do
      user.grant(:edit, match.away_team.team)
      sign_in user

      patch :defer, params: { id: pick_ban.id }

      match.reload
      expect(pick_ban.reload.home_team?).to be(true)
      expect(match.pick_bans.length).to eq(1)
      expect(match.rounds).to be_empty
      expect(response).to redirect_to(match_path(match))
    end

    it 'redirects for authorized admin when not deferrable' do
      pick_ban.update!(deferrable: false)
      user.grant(:edit, pick_ban.league)
      sign_in user

      patch :defer, params: { id: pick_ban.id }

      match.reload
      expect(pick_ban.reload.home_team?).to be(true)
      expect(match.pick_bans.length).to eq(1)
      expect(match.rounds).to be_empty
      expect(response).to redirect_to(match_path(match))
    end

    it 'redirects for unauthorized user' do
      sign_in user

      patch :defer, params: { id: pick_ban.id }

      match.reload
      expect(pick_ban.reload.home_team?).to be(true)
      expect(match.pick_bans.length).to eq(1)
      expect(match.rounds).to be_empty
      expect(response).to redirect_to(match_path(match))
    end

    it 'redirects for unauthenticated user' do
      patch :defer, params: { id: pick_ban.id }

      match.reload
      expect(pick_ban.reload.home_team?).to be(true)
      expect(match.pick_bans.length).to eq(1)
      expect(match.rounds).to be_empty
      expect(response).to redirect_to(match_path(match))
    end
  end
end
