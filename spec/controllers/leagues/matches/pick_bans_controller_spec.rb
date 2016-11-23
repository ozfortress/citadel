require 'rails_helper'

describe Leagues::Matches::PickBansController do
  let(:user) { create(:user) }
  let(:pick_ban) { create(:league_match_pick_ban, kind: :pick, team: :home_team) }
  let(:match) { pick_ban.match }
  let(:map) { create(:map) }

  describe 'PATCH submit' do
    it 'succeeds for authorized admin' do
      user.grant(:edit, pick_ban.league)
      sign_in user

      patch :submit, params: { match_id: match.id, id: pick_ban.id,
                               pick_ban: { map_id: map.id } }

      expect(match.reload.rounds.length).to eq(1)
      expect(response).to redirect_to(match_path(match))
    end

    it 'succeeds for authorized captain on home_team' do
      user.grant(:edit, match.home_team.team)
      sign_in user

      patch :submit, params: { match_id: match.id, id: pick_ban.id,
                               pick_ban: { map_id: map.id } }

      expect(match.reload.rounds.length).to eq(1)
      expect(response).to redirect_to(match_path(match))
    end

    it 'redirects for authorized captain on away_team' do
      user.grant(:edit, match.away_team.team)
      sign_in user

      patch :submit, params: { match_id: match.id, id: pick_ban.id,
                               pick_ban: { map_id: map.id } }

      expect(match.reload.rounds).to be_empty
      expect(response).to redirect_to(match_path(match))
    end

    it 'redirects for unauthorized user' do
      sign_in user

      patch :submit, params: { match_id: match.id, id: pick_ban.id,
                               pick_ban: { map_id: map.id } }

      expect(match.reload.rounds).to be_empty
      expect(response).to redirect_to(match_path(match))
    end

    it 'redirects for unauthenticated user' do
      patch :submit, params: { match_id: match.id, id: pick_ban.id,
                               pick_ban: { map_id: map.id } }

      expect(match.reload.rounds).to be_empty
      expect(response).to redirect_to(match_path(match))
    end
  end
end
