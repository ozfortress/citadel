require 'rails_helper'

describe Leagues::MatchesController do
  before(:all) do
    @map = create(:map)
    @map2 = create(:map)

    @league = create(:league, matches_submittable: true)
    @div = create(:league_division, league: @league)
    @div2 = create(:league_division, league: @league)

    @team1 = create(:league_roster, division: @div)
    @team2 = create(:league_roster, division: @div)
    @team3 = create(:league_roster, division: @div2)

    @admin = create(:user)
    @admin.grant(:edit, @league)

    @captain1 = create(:user)
    @captain1.grant(:edit, @team1.team)

    @captain2 = create(:user)
    @captain2.grant(:edit, @team2.team)

    @user = create(:user)
  end

  describe 'GET #index' do
    it 'succeeds for authorized user' do
      sign_in @admin

      get :index, params: { league_id: @league.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'succeeds for authorized user' do
      sign_in @admin

      get :new, params: { league_id: @league.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      sign_in @admin

      post :create, params: {
        league_id: @league.id, division_id: @div.id, match: {
          home_team_id: @team1.id, away_team_id: @team2.id, round_name: 'foo',
          round_number: 3, notice: 'B',
          rounds_attributes: [
            { map_id: @map.id }
          ]
        }
      }

      @league.reload
      match = @league.matches.first
      expect(match).to_not be nil
      expect(match.home_team).to eq(@team1)
      expect(match.away_team).to eq(@team2)
      expect(match.round_name).to eq('foo')
      expect(match.round_number).to eq(3)
      expect(match.notice).to eq('B')
      expect(match.rounds.count).to eq(1)
      round = match.rounds.first
      expect(round.map).to eq(@map)
      (@team1.users + @team2.users).each do |user|
        expect(user.notifications).to_not be_empty
      end
    end

    it 'succeeds for authorized user with bye match' do
      sign_in @admin

      post :create, params: {
        league_id: @league.id, division_id: @div.id, match: {
          home_team_id: @team1.id, away_team_id: nil, round_name: 'foo',
          round_number: 3, notice: 'B',
        }
      }

      @league.reload
      match = @league.matches.first
      expect(match).to_not be nil
      expect(match.bye?).to be true
      expect(match.home_team).to eq(@team1)
      expect(match.away_team).to be nil
      expect(match.round_name).to eq('foo')
      expect(match.round_number).to eq(3)
      expect(match.notice).to eq('B')
      expect(match.rounds).to be_empty
      @team1.users.each do |user|
        expect(user.notifications).to_not be_empty
      end
      @team2.users.each do |user|
        expect(user.notifications).to be_empty
      end
    end

    it 'fails with invalid data' do
      sign_in @admin

      post :create, params: {
        league_id: @league.id, division_id: @div.id, match: {
          home_team_id: @team1.id, away_team_id: @team1.id,
        }
      }

      expect(League::Match.all).to be_empty
      expect(response).to have_http_status(:success)
    end

    it 'redirects for unauthorized user' do
      sign_in @user

      post :create, params: { league_id: @league.id }

      expect(response).to redirect_to(league_path(@league))
    end

    it 'redirects for unauthenticated user' do
      post :create, params: { league_id: @league.id }

      expect(response).to redirect_to(league_path(@league))
    end
  end

  describe 'GET #generate' do
    it 'succeeds for authorized user' do
      sign_in @admin

      get :generate, params: { league_id: @league.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create_round' do
    it 'succeeds with swiss system for authorized user' do
      sign_in @admin

      post :create_round, params: {
        league_id: @league.id,
        division_id: @div.id,
        match: {
          round_name: 'foo', round_number: 3, notice: 'B', rounds_attributes: [{ map_id: @map.id }]
        },
        tournament_system: :swiss,
        swiss_tournament: { pairer: :dutch, pair_options: { min_pair_size: 2 } },
        single_elimination_tournament: { teams_limit: 0, round: 0 },
        page_playoffs_tournament: { starting_round: 0 },
      }

      expect(@league.matches.size).to eq(1)
      @league.matches.each do |match|
        expect(match.round_name).to eq('foo')
        expect(match.round_number).to eq(3)
        expect(match.notice).to eq('B')
        expect(match.rounds.size).to eq(1)
        expect(match.rounds.first.map).to eq(@map)

        (match.home_team.users + match.away_team.users).each do |user|
          expect(user.notifications).to_not be_empty
        end
      end
    end

    it 'fails with invalid data' do
      sign_in @admin

      post :create_round, params: {
        league_id: @league.id, division_id: @div.id, match: { round_number: -1 },
        tournament_system: :swiss,
        swiss_tournament: { pairer: :dutch, pair_options: { min_pair_size: 2 } },
        single_elimination_tournament: { teams_limit: 0, round: 0 },
        page_playoffs_tournament: { starting_round: 0 },
      }

      @league.reload
      expect(@league.matches).to be_empty
    end
  end

  context 'existing match' do
    let!(:match) { create(:league_match, home_team: @team1, away_team: @team2) }
    let!(:round) { create(:league_match_round, match: match) }

    describe 'GET #show' do
      it 'succeeds' do
        get :show, params: { id: match.id }

        expect(response).to have_http_status(:success)
      end

      it 'succeeds for bye match' do
        match.update!(away_team: nil)

        get :show, params: { id: match.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #edit' do
      it 'succeeds for authorized user' do
        sign_in @admin

        get :edit, params: { id: match.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH #update' do
      it 'succeeds for authorized user' do
        sign_in @admin

        patch :update, params: {
          id: match.id, match: {
            home_team_id: @team2.id, away_team_id: @team1.id, round_name: 'foo', round_number: 5,
            rounds_attributes: [
              { id: round.id, _destroy: true, map_id: @map.id },
              { map_id: @map2.id },
            ]
          }
        }

        match.reload
        expect(match).to_not be(nil)
        expect(match.home_team).to eq(@team2)
        expect(match.away_team).to eq(@team1)
        expect(match.round_name).to eq('foo')
        expect(match.round_number).to eq(5)
        round = match.rounds.first
        expect(round.map).to eq(@map2)
      end

      it 'fails with invalid data' do
        sign_in @admin

        patch :update, params: {
          id: match.id, match: {
            home_team_id: @team1.id, away_team_id: @team1.id
          }
        }

        match.reload
        expect(match.away_team).to eq(@team2)
      end
    end

    describe 'PATCH #submit' do
      let!(:round) { create(:league_match_round, match: match) }

      it 'succeeds for admin user' do
        sign_in @admin

        patch :submit, params: {
          id: match.id, match: {
            status: :confirmed, rounds_attributes: {
              id: round.id, home_team_score: 2, away_team_score: 5,
            }
          }
        }

        match.reload
        expect(match.status).to eq('confirmed')
        expect(match.rounds.size).to eq(1)
        round.reload
        expect(round.home_team_score).to eq(2)
        expect(round.away_team_score).to eq(5)
      end

      it 'succeeds for admin user ff' do
        sign_in @admin

        patch :submit, params: {
          id: match.id, match: { forfeit_by: :home_team_forfeit }
        }

        match.reload
        expect(match.status).to eq('confirmed')
        expect(match.forfeit_by).to eq('home_team_forfeit')
      end

      it 'succeeds for home team authorized user' do
        sign_in @captain1

        patch :submit, params: {
          id: match.id, match: {
            rounds_attributes: { id: round.id, home_team_score: 2, away_team_score: 5 }
          }
        }

        match.reload
        expect(match.status).to eq('submitted_by_home_team')
        expect(match.rounds.size).to eq(1)
        round.reload
        expect(round.home_team_score).to eq(2)
        expect(round.away_team_score).to eq(5)
      end

      it 'succeeds for away team authorized user' do
        sign_in @captain2

        patch :submit, params: {
          id: match.id, match: {
            rounds_attributes: {
              id: round.id, home_team_score: 2, away_team_score: 5,
            }
          }
        }

        match.reload
        expect(match.status).to eq('submitted_by_away_team')
        expect(match.rounds.size).to eq(1)
        round.reload
        expect(round.home_team_score).to eq(2)
        expect(round.away_team_score).to eq(5)
      end

      it 'fails with invalid data' do
        sign_in @captain1

        patch :submit, params: {
          id: match.id, match: {
            rounds_attributes: {
              id: round.id, home_team_score: -1, away_team_score: 5,
            }
          }
        }

        match.reload
        expect(match.status).to eq('pending')
      end

      it "doesn't allow status changes for non-admins with invalid data" do
        sign_in @captain1

        patch :submit, params: {
          id: match.id, match: {
            status: :confirmed, rounds_attributes: {
              id: round.id, home_team_score: 2, away_team_score: 5,
            }
          }
        }

        match.reload
        expect(match.status).to eq('submitted_by_home_team')
        expect(response).to redirect_to(match_path(match))
      end

      it "doesn't allow score submission overriding" do
        match.update!(status: 'submitted_by_home_team')
        sign_in @captain2

        patch :submit, params: {
          id: match.id, match: {
            rounds_attributes: {
              id: round.id, home_team_score: 2, away_team_score: 5,
            }
          }
        }

        match.reload
        expect(match.status).to eq('submitted_by_home_team')
        expect(response).to redirect_to(match_path(match))
      end
    end

    describe 'PATCH #confirm' do
      before do
        match.update!(status: :submitted_by_home_team)
      end

      let!(:round) do
        create(:league_match_round, match: match, home_team_score: 2, away_team_score: 3)
      end

      it 'succeeds for admin user' do
        sign_in @admin

        patch :confirm, params: { id: match.id, confirm: 'true' }

        match.reload
        expect(match.confirmed?).to be true
      end

      it 'fails for home team authorized user' do
        sign_in @captain1

        patch :confirm, params: { id: match.id, confirm: 'true' }

        match.reload
        expect(match.status).to eq('submitted_by_home_team')
      end

      it 'succeeds for away team authorized user' do
        sign_in @captain2

        patch :confirm, params: { id: match.id, confirm: 'true' }

        match.reload
        expect(match.status).to eq('confirmed')
      end
    end

    describe 'PATCH #forfeit' do
      let!(:round) { create(:league_match_round, match: match) }

      it 'succeeds for home team authorized user' do
        sign_in @captain1

        patch :forfeit, params: { id: match.id }

        match.reload
        expect(match.status).to eq('confirmed')
        expect(match.forfeit_by).to eq('home_team_forfeit')
      end

      it 'succeeds for away team authorized user' do
        sign_in @captain2

        patch :forfeit, params: { id: match.id }

        match.reload
        expect(match.status).to eq('confirmed')
        expect(match.forfeit_by).to eq('away_team_forfeit')
      end

      it 'fails when match is already forfeit' do
        sign_in @captain1

        match.update!(forfeit_by: :away_team_forfeit)

        patch :forfeit, params: { id: match.id }

        match.reload
        expect(match.forfeit_by).to eq('away_team_forfeit')
        expect(response).to redirect_to(match_path(match))
      end
    end

    describe 'DELETE #destroy' do
      it 'succeeds for authorized user' do
        sign_in @admin

        delete :destroy, params: { id: match.id }

        expect(League::Match.exists?(match.id)).to be(false)
      end

      it 'fails for team authorized user' do
        sign_in @captain1

        delete :destroy, params: { id: match.id }

        expect(League::Match.exists?(match.id)).to be(true)
      end

      it 'fails for unauthorized user' do
        sign_in @user

        delete :destroy, params: { id: match.id }

        expect(League::Match.exists?(match.id)).to be(true)
      end

      it 'fails for unauthenticated user' do
        delete :destroy, params: { id: match.id }

        expect(League::Match.exists?(match.id)).to be(true)
      end
    end
  end
end
