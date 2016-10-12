require 'rails_helper'

describe Leagues::RostersController do
  let(:user) { create(:user) }
  let(:team) { create(:team) }
  let(:league) { create(:league, signuppable: true, min_players: 1) }
  let!(:div) { create(:league_division, league: league) }
  let!(:div2) { create(:league_division, league: league) }

  before do
    team.add_player!(user)
  end

  describe 'GET #new' do
    it 'succeeds for authorized user' do
      user.grant(:edit, team)
      sign_in user

      get :new, params: { league_id: league.id }

      expect(response).to have_http_status(:success)
    end

    it 'succeeds for authorized user with selected team' do
      user.grant(:edit, team)
      sign_in user

      get :new, params: { league_id: league.id, team_id: team.id }

      expect(response).to have_http_status(:success)
    end

    it 'redirects for unauthorized user' do
      sign_in user

      get :new, params: { league_id: league.id }

      expect(response).to redirect_to(league_path(league.id))
    end

    it 'redirects for unauthenticated user' do
      get :new, params: { league_id: league.id }

      expect(response).to redirect_to(league_path(league.id))
    end
  end

  describe 'POST #create' do
    it 'succeeds for authorized user' do
      other_user = create(:user)
      team.add_player!(other_user)
      user.grant(:edit, team)
      sign_in user

      post :create, params: {
        league_id: league.id, team_id: team.id,
        roster: { name: 'A', description: 'B',
                  division_id: div2.id, players_attributes: [{ user_id: user.id }] }
      }

      roster = League::Roster.first
      expect(roster).to_not be(nil)
      expect(roster.name).to eq('A')
      expect(roster.description).to eq('B')
      expect(roster.team).to eq(team)
      expect(roster.users).to eq([user])
      expect(roster.division).to eq(div2)
      expect(user.notifications).to_not be_empty
      expect(other_user.notifications).to be_empty
    end

    it 'fails for too little players' do
      user.grant(:edit, team)
      sign_in user

      post :create, params: {
        league_id: league.id, team_id: team.id,
        roster: { name: 'A', description: 'B',
                  division_id: div.id, players_attributes: [] }
      }
    end

    it 'redirects for unauthorized user for team' do
      team2 = create(:team)
      user.grant(:edit, team2)
      sign_in user

      post :create, params: { league_id: league.id, team_id: team.id }

      expect(response).to redirect_to(league_path(league.id))
    end

    it 'redirects for unauthorized user' do
      sign_in user

      post :create, params: { league_id: league.id, team_id: team.id }

      expect(response).to redirect_to(league_path(league.id))
    end

    it 'redirects for unauthenticated user' do
      post :create, params: { league_id: league.id, team_id: team.id }

      expect(response).to redirect_to(league_path(league.id))
    end
  end

  context 'existing roster' do
    let(:roster) { create(:league_roster, division: div, team: team) }

    describe 'GET #show' do
      it 'succeeds' do
        get :show, params: { league_id: league.id, id: roster.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #edit' do
      it 'succeeds for authorized captain' do
        user.grant(:edit, roster.team)
        sign_in user

        get :edit, params: { league_id: league.id, id: roster.id }

        expect(response).to have_http_status(:success)
      end

      it 'succeeds for authorized admin' do
        user.grant(:edit, league)
        sign_in user

        get :edit, params: { league_id: league.id, id: roster.id }

        expect(response).to have_http_status(:success)
      end

      it 'redirects for authorized captain if team disbanded' do
        user.grant(:edit, roster.team)
        league.update!(signuppable: false)
        roster.disband
        sign_in user

        get :edit, params: { league_id: league.id, id: roster.id }

        expect(response).to redirect_to(league_roster_path(league, roster))
      end
    end

    describe 'PATCH #update' do
      it 'succeeds for authorized admin' do
        user.grant(:edit, league)
        sign_in user

        patch :update, params: {
          league_id: league.id, id: roster.id,
          roster: { name: 'A', description: 'B', division_id: div2, seeding: 2, ranking: 3 }
        }

        roster.reload
        expect(roster.name).to eq('A')
        expect(roster.description).to eq('B')
        expect(roster.division).to eq(div2)
        expect(roster.seeding).to eq(2)
        expect(roster.ranking).to eq(3)
      end

      it 'succeeds for authorized captain' do
        user.grant(:edit, roster.team)
        sign_in user

        patch :update, params: {
          league_id: league.id, id: roster.id,
          roster: { name: 'A', description: 'B', division_id: div2, seeding: 2, ranking: 3 }
        }

        roster.reload
        expect(roster.description).to eq('B')
        expect(roster.division).to eq(div)
        expect(roster.name).to_not eq('A')
        expect(roster.seeding).to_not eq(2)
        expect(roster.ranking).to_not eq(3)
      end

      it 'succeeds for authorized captain with locked schedule' do
        user.grant(:edit, roster.team)
        league.update!(schedule: :weeklies, schedule_locked: true,
                       weekly_scheduler: build(:league_schedulers_weekly))
        roster.schedule_data = league.scheduler.default_schedule
        roster.save!
        sign_in user

        patch :update, params: {
          league_id: league.id, id: roster.id, roster: {
            description: 'B', division_id: div2, schedule_data: { foo: 'bar' } },
        }

        roster.reload
        expect(roster.description).to eq('B')
        expect(roster.division).to eq(div)
      end

      it 'fails with invalid data' do
        user.grant(:edit, league)
        sign_in user

        patch :update, params: {
          league_id: league.id, id: roster.id,
          roster: { name: '', description: 'B', division_id: div2 }
        }

        roster.reload
        expect(roster.name).not_to eq('')
        expect(roster.description).to_not eq('B')
      end

      it 'redirects for authorized captain if team disbanded' do
        user.grant(:edit, roster.team)
        league.update!(signuppable: false)
        expect(roster.disband).to be(true)
        sign_in user

        patch :update, params: {
          league_id: league.id, id: roster.id, roster: { description: 'B' }
        }

        roster.reload
        expect(roster.description).to_not eq('B')
        expect(roster.division).to eq(div)
      end

      it 'redirects for unauthorized user' do
        sign_in user

        patch :update, params: { league_id: league.id, id: roster.id }

        expect(response).to redirect_to(league_roster_path(league.id, roster))
      end

      it 'redirects for unauthenticated user' do
        patch :update, params: { league_id: league.id, id: roster.id }

        expect(response).to redirect_to(league_roster_path(league.id, roster))
      end
    end

    describe 'GET #review' do
      before do
        roster.update!(approved: false)
      end

      it 'succeeds for authorized user' do
        user.grant(:edit, league)
        sign_in user

        get :review, params: { league_id: league.id, id: roster.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH #approve' do
      before do
        roster.update!(approved: false)
      end

      it 'succeeds for authorized user' do
        user.grant(:edit, league)
        sign_in user

        patch :approve, params: {
          league_id: league.id, id: roster.id,
          roster: { name: 'A', division_id: div2.id, seeding: 2 }
        }

        roster.reload
        expect(roster.name).to eq('A')
        expect(roster.division).to eq(div2)
        expect(roster.seeding).to eq(2)
      end

      it 'fails with invalid name' do
        user.grant(:edit, league)
        sign_in user

        patch :approve, params: {
          league_id: league.id, id: roster.id,
          roster: { name: '', division_id: div2.id }
        }

        roster.reload
        expect(roster.name).to_not eq('')
      end

      it 'redirects for approved roster' do
        roster.update!(approved: true)
        user.grant(:edit, league)
        sign_in user

        patch :approve, params: {
          league_id: league.id, id: roster.id,
          roster: { name: 'A', division_id: div2.id, seeding: 2 }
        }

        expect(response).to redirect_to(league_path(league.id))
      end

      it 'redirects for unauthorized user' do
        sign_in user

        patch :approve, params: { league_id: league.id, id: roster.id }

        expect(response).to redirect_to(league_path(league.id))
      end

      it 'redirects for unauthenticated user' do
        patch :approve, params: { league_id: league.id, id: roster.id }

        expect(response).to redirect_to(league_path(league.id))
      end
    end

    describe 'DELETE #disband' do
      it 'succeeds for authorized admin' do
        user.grant(:edit, league)
        sign_in user

        delete :disband, params: { league_id: league.id, id: roster.id }

        expect(roster.reload.disbanded?).to be(true)
      end

      it 'succeeds for authorized captain if league allows disbands' do
        league.update!(allow_disbanding: true)
        user.grant(:edit, team)
        sign_in user

        delete :disband, params: { league_id: league.id, id: roster.id }

        expect(roster.reload.disbanded?).to be(true)
      end

      it 'redirects for authorized captain' do
        user.grant(:edit, team)
        sign_in user

        delete :disband, params: { league_id: league.id, id: roster.id }

        expect(roster.reload.disbanded?).to be(false)
        expect(response).to redirect_to(league_roster_path(league, roster))
      end

      it 'redirects for unauthorized user' do
        sign_in user

        delete :disband, params: { league_id: league.id, id: roster.id }

        expect(roster.reload.disbanded?).to be(false)
        expect(response).to redirect_to(league_roster_path(league, roster))
      end

      it 'redirects for unauthenticated user' do
        delete :disband, params: { league_id: league.id, id: roster.id }

        expect(roster.reload.disbanded?).to be(false)
        expect(response).to redirect_to(league_roster_path(league, roster))
      end
    end

    describe 'DELETE #destroy' do
      it 'succeeds for authorized admin' do
        user.grant(:edit, league)
        sign_in user

        delete :destroy, params: { league_id: league.id, id: roster.id }

        expect(League::Roster.exists?(roster.id)).to be(false)
        expect(response).to redirect_to(league_path(league))
      end

      it 'redirects for authorized admin when roster has matches' do
        create(:league_match, home_team: roster)
        user.grant(:edit, league)
        sign_in user

        delete :destroy, params: { league_id: league.id, id: roster.id }

        expect(roster.reload.disbanded?).to be(false)
        expect(response).to redirect_to(league_roster_path(league, roster))
      end

      it 'redirects for authorized team captain' do
        user.grant(:edit, team)
        sign_in user

        delete :destroy, params: { league_id: league.id, id: roster.id }

        expect(League::Roster.exists?(roster.id)).to be(true)
        expect(response).to redirect_to(league_roster_path(league, roster))
      end

      it 'redirects for unauthorized user' do
        sign_in user

        delete :destroy, params: { league_id: league.id, id: roster.id }

        expect(League::Roster.exists?(roster.id)).to be(true)
        expect(response).to redirect_to(league_roster_path(league, roster))
      end

      it 'redirects for unauthenticated user' do
        delete :destroy, params: { league_id: league.id, id: roster.id }

        expect(League::Roster.exists?(roster.id)).to be(true)
        expect(response).to redirect_to(league_roster_path(league, roster))
      end
    end
  end
end
