require 'rails_helper'

describe TeamsController do
  let(:user) { create(:user) }

  describe 'GET #index' do
    before do
      create_list(:team, 50)
    end

    it 'succeeds' do
      get :index

      expect(response).to have_http_status(:success)
    end

    it 'succeeds with search' do
      get :index, params: { q: 'foo' }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'succeeds' do
      sign_in user

      get :new

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'creates a team' do
      sign_in user

      post :create, params: { team: { name: 'A', description: 'B' } }

      team = Team.find_by(name: 'A')
      expect(team).to_not be_nil
      expect(team.description).to eq('B')
      expect(team.on_roster?(user)).to be(true)
      expect(user.can?(:edit, team)).to be(true)
    end

    it 'handles duplicate teams' do
      create(:team, name: 'A', description: 'A')
      sign_in user

      post :create, params: { team: { name: 'A', description: 'B' } }

      expect(Team.count).to eq(1)
    end

    it 'redirects for banned users' do
      user.ban(:use, :teams)
      sign_in user

      post :create, params: { team: { name: 'A', description: 'B' } }

      expect(Team.all).to be_empty
      expect(response).to redirect_to(teams_path)
    end
  end

  context 'existing team' do
    let(:team) { create(:team, name: 'A', description: 'B') }

    describe 'GET #show' do
      it 'succeeds' do
        get :show, params: { id: team.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #edit' do
      it 'succeeds' do
        user.grant(:edit, team)
        sign_in user

        get :edit, params: { id: team.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH #update' do
      it 'updates a team' do
        user.grant(:edit, team)
        sign_in user

        patch :update, params: { id: team.id, team: { name: 'C', description: 'D' } }

        team.reload
        expect(team.name).to eq('C')
        expect(team.description).to eq('D')
        expect(response).to redirect_to(team_path(team))
      end

      it 'allows admins to edit teams' do
        user.grant(:edit, :teams)
        sign_in user

        patch :update, params: { id: team.id, team: {
          name: 'C', description: 'D', notice: 'foo'
        } }

        team.reload
        expect(team.name).to eq('C')
        expect(team.description).to eq('D')
        expect(team.notice).to eq('foo')
        expect(response).to redirect_to(team_path(team))
      end

      it 'allows avatar removal' do
        team = create(:team_with_avatar)
        user.grant(:edit, team)
        sign_in user

        patch :update, params: { id: team.id, team: { remove_avatar: true } }

        team.reload
        expect(team.avatar.url).to eq(team.avatar.default_url)
        expect(response).to redirect_to(team_path(team))
      end

      it 'fails for invalid data' do
        user.grant(:edit, team)
        sign_in user

        patch :update, params: { id: team.id, team: { name: '', description: '' } }

        team.reload
        expect(team.name).to eq('A')
        expect(team.description).to eq('B')
        expect(response).to have_http_status(:success)
      end

      it 'redirects for banned user' do
        user.grant(:edit, team)
        user.ban(:use, :teams)
        sign_in user

        patch :update, params: { id: team.id, team: { name: 'C', description: 'D' } }

        team.reload
        expect(team.name).to eq('A')
        expect(team.description).to eq('B')
        expect(response).to redirect_to(team_path(team))
      end

      it 'redirects for unauthorized user' do
        sign_in user

        patch :update, params: { id: team.id, team: { name: 'C', description: 'D' } }

        team.reload
        expect(team.name).to eq('A')
        expect(team.description).to eq('B')
        expect(response).to redirect_to(team_path(team))
      end

      it 'redirects for unauthenticated user' do
        patch :update, params: { id: team.id, team: { name: 'C', description: 'D' } }

        team.reload
        expect(team.name).to eq('A')
        expect(team.description).to eq('B')
        expect(response).to redirect_to(team_path(team))
      end
    end

    describe 'GET #recruit' do
      before { create_list(:user, 20) }

      it 'succeeds' do
        user.grant(:edit, team)
        sign_in user

        get :recruit, params: { id: team.id }

        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH #invite' do
      let(:invited) { create(:user) }

      it 'invites a player to a team' do
        user.grant(:edit, team)
        sign_in user

        patch :invite, params: { id: team.id, user_id: invited.id }

        invite = invited.team_invites.first
        expect(invite).to_not be_nil
        expect(invite.user).to eq(invited)
        expect(invite.team).to eq(team)
        expect(team.invited?(invited)).to be(true)
        expect(invited.notifications).to_not be_empty
        expect(user.notifications).to be_empty
      end

      it 'redirects for banned user' do
        user.grant(:edit, team)
        user.ban(:use, :teams)
        sign_in user

        patch :invite, params: { id: team.id, user_id: invited.id }

        expect(invited.team_invites).to be_empty
        expect(invited.notifications).to be_empty
        expect(response).to redirect_to(team_path(team))
      end

      it 'redirects for unauthorized user' do
        sign_in user

        patch :invite, params: { id: team.id, user_id: invited.id }

        expect(invited.team_invites).to be_empty
        expect(invited.notifications).to be_empty
        expect(response).to redirect_to(team_path(team))
      end

      it 'redirects for unauthenticated user' do
        patch :invite, params: { id: team.id, user_id: invited.id }

        expect(invited.team_invites).to be_empty
        expect(invited.notifications).to be_empty
        expect(response).to redirect_to(team_path(team))
      end
    end

    context 'player on team' do
      let(:player) { create(:user) }

      before do
        team.add_player!(user)
        team.add_player!(player)
      end

      describe 'PATCH #kick' do
        it 'succeeds for captain' do
          user.grant(:edit, team)
          sign_in user

          patch :kick, params: { id: team.id, user_id: player.id }

          expect(team.on_roster?(player)).to be(false)
          expect(team.invited?(player)).to be(false)
          expect(player.notifications).to_not be_empty
          expect(user.notifications).to be_empty
          expect(response).to redirect_to(team_path(team))
        end

        it 'revokes captain permissions' do
          user.grant(:edit, team)
          sign_in user

          patch :kick, params: { id: team.id, user_id: user.id }

          user.reload
          expect(team.on_roster?(user)).to be(false)
          expect(user.can?(:edit, team)).to be(false)
        end

        it 'fails for player' do
          sign_in player

          patch :kick, params: { id: team.id, user_id: player.id }

          expect(team.on_roster?(player)).to be(true)
        end

        it 'fails for unauthorized user' do
          sign_in user

          patch :kick, params: { id: team.id, user_id: player.id }

          expect(team.on_roster?(player)).to be(true)
        end

        it 'fails for unauthenticated user' do
          patch :kick, params: { id: team.id, user_id: player.id }

          expect(team.on_roster?(player)).to be(true)
        end
      end

      describe 'PATCH #leave' do
        it 'succeeds for player' do
          user.grant(:edit, team)
          sign_in player

          patch :leave, params: { id: team.id }

          team.reload
          expect(team.on_roster?(player)).to be(false)
          expect(team.invited?(player)).to be(false)
          expect(player.notifications).to be_empty
          expect(user.notifications).to_not be_empty
          expect(response).to redirect_to(team_path(team))
        end

        it 'revokes captain permissions' do
          user.grant(:edit, team)
          sign_in user

          patch :leave, params: { id: team.id }

          user.reload
          expect(team.on_roster?(user)).to be(false)
          expect(user.can?(:edit, team)).to be(false)
        end

        it 'fails for captain' do
          user.grant(:edit, team)
          sign_in user

          patch :leave, params: { id: team.id }

          expect(team.on_roster?(player)).to be(true)
        end

        it 'fails for other users' do
          sign_in user

          patch :leave, params: { id: team.id }

          expect(team.on_roster?(player)).to be(true)
        end

        it 'fails for unauthenticated user' do
          patch :leave, params: { id: team.id }

          expect(team.on_roster?(player)).to be(true)
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:invited) { create(:user) }

      before do
        team.add_player!(user)
        invited.grant(:edit, team)
        team.invite(invited)
      end

      it 'succeeds for authorized user' do
        user.grant(:edit, :teams)
        sign_in user

        delete :destroy, params: { id: team.id }

        expect(Team.all).to be_empty
      end

      it 'succeeds for authorized captains' do
        invited.grant(:edit, team)
        sign_in invited

        delete :destroy, params: { id: team.id }

        expect(Team.all).to be_empty
      end

      it 'fails for banned user' do
        user.grant(:edit, team)
        user.ban(:use, :teams)
        sign_in user

        delete :destroy, params: { id: team.id }

        expect(Team.where(id: team.id)).to exist
      end

      it 'fails for unauthorized user' do
        sign_in user

        delete :destroy, params: { id: team.id }

        expect(Team.where(id: team.id)).to exist
      end

      it 'fails for unauthenticated user' do
        delete :destroy, params: { id: team.id }

        expect(Team.where(id: team.id)).to exist
      end
    end
  end
end
