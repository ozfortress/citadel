require 'rails_helper'

describe League::Roster::TransferRequest do
  before(:all) { create(:league_roster_transfer_request, propagate: true) }

  it { should belong_to(:roster) }
  it { should_not allow_value(nil).for(:roster) }

  it { should belong_to(:leaving_roster) }
  it { should allow_value(nil).for(:leaving_roster) }

  it { should belong_to(:user) }
  it { should_not allow_value(nil).for(:user) }

  it { should belong_to(:created_by) }
  it { should_not allow_value(nil).for(:created_by) }

  it { should belong_to(:approved_by) }
  it { should allow_value(nil).for(:approved_by) }

  it { should belong_to(:denied_by) }
  it { should allow_value(nil).for(:denied_by) }

  describe '#approve' do
    it 'succeeds when joining' do
      user = create(:user)
      division = create(:league_division)
      division.league.update!(min_players: 1, max_players: 2)
      roster = create(:league_roster, division: division)
      roster2 = create(:league_roster, division: division)
      roster2.add_player!(user)
      request = create(:league_roster_transfer_request, roster: roster, user: user, propagate: true)

      expect(request.approve(user)).to be_truthy
      expect(roster.on_roster?(user)).to be(true)
      expect(roster2.on_roster?(user)).to be(false)
      expect(request.reload).to be_approved
    end

    it 'succeeds when leaving' do
      roster = create(:league_roster, player_count: 3)
      user = roster.users.first
      request = create(:league_roster_transfer_request,
                       roster: roster, user: user, is_joining: false)

      expect(request.approve(user)).to be_truthy
      expect(roster.on_roster?(user)).to be(false)
      expect(request.reload).to be_approved
    end

    it 'handles dependent transfers at minimum' do
      roster = create(:league_roster, player_count: 2)
      roster.league.update!(min_players: 2, max_players: 3)
      request1 = create(:league_roster_transfer_request, roster: roster, propagate: true)
      user = roster.users.first
      request2 = create(:league_roster_transfer_request, roster: roster, user: user, is_joining: false)

      expect(request2.approve(user)).to be_falsey
      expect(roster.on_roster?(user)).to be true
      expect(request2.reload).to be_pending

      expect(request1.approve(user)).to be_truthy
      expect(roster.on_roster?(request1.user)).to be true
      expect(request1.reload).to be_approved

      expect(request2.approve(user)).to be_truthy
      expect(roster.on_roster?(user)).to be false
      expect(request2.reload).to be_approved
    end

    it 'handles dependent transfers at maximum' do
      roster = create(:league_roster, player_count: 2)
      roster.league.update!(min_players: 1, max_players: 2)
      user = roster.users.first
      request1 = create(:league_roster_transfer_request, roster: roster, user: user, is_joining: false)
      request2 = create(:league_roster_transfer_request, roster: roster, propagate: true)

      expect(request2.approve(user)).to be_falsey
      expect(roster.on_roster?(request2.user)).to be false
      expect(request2.reload).to be_pending

      expect(request1.approve(user)).to be_truthy
      expect(roster.on_roster?(user)).to be false
      expect(request1.reload).to be_approved

      expect(request2.approve(user)).to be_truthy
      expect(roster.on_roster?(request2.user)).to be true
      expect(request2.reload).to be_approved
    end

    it 'handles roster size above maximum' do
      roster = create(:league_roster, player_count: 3)
      roster.league.update!(min_players: 1, max_players: 2)
      user = roster.users.first

      request = create(:league_roster_transfer_request, roster: roster, user: user, is_joining: false)

      expect(request.approve(user)).to be_truthy
      expect(roster.on_roster?(user)).to be false
      expect(request.reload).to be_approved
    end
  end

  describe '#deny' do
    it 'succeeds when joining' do
      request = create(:league_roster_transfer_request, propagate: true)
      user = request.user
      roster = request.roster
      roster2 = create(:league_roster, division: request.division)
      roster2.add_player!(request.user)

      expect(request.deny(user)).to be_truthy
      expect(roster.on_roster?(user)).to be(false)
      expect(roster2.on_roster?(user)).to be(true)
      expect(request.reload).to be_denied
    end

    it 'succeeds when leaving' do
      roster = create(:league_roster, player_count: 3)
      user = roster.users.first
      request = create(:league_roster_transfer_request,
                       roster: roster, user: user, is_joining: false)

      expect(request.deny(user)).to be_truthy
      expect(roster.on_roster?(user)).to be(true)
      expect(request.reload).to be_denied
    end

    it 'handles dependent transfers at minimum' do
      roster = create(:league_roster, player_count: 2)
      roster.league.update!(min_players: 2, max_players: 3)
      request1 = create(:league_roster_transfer_request, roster: roster, propagate: true)
      user = roster.users.first
      request2 = create(:league_roster_transfer_request, roster: roster, user: user, is_joining: false)

      expect(request1.deny(user)).to be_falsey
      expect(roster.on_roster?(request1.user)).to be false
      expect(request1.reload).to be_pending

      expect(request2.deny(user)).to be_truthy
      expect(roster.on_roster?(user)).to be true
      expect(request2.reload).to be_denied

      expect(request1.deny(user)).to be_truthy
      expect(roster.on_roster?(request1.user)).to be false
      expect(request1.reload).to be_denied
    end

    it 'handles dependent transfers at maximum' do
      roster = create(:league_roster, player_count: 2)
      roster.league.update!(min_players: 1, max_players: 2)
      user = roster.users.first
      request1 = create(:league_roster_transfer_request, roster: roster, user: user, is_joining: false)
      request2 = create(:league_roster_transfer_request, roster: roster, propagate: true)

      expect(request1.deny(user)).to be_falsey
      expect(roster.on_roster?(user)).to be true
      expect(request1.reload).to be_pending

      expect(request2.deny(user)).to be_truthy
      expect(roster.on_roster?(request2.user)).to be false
      expect(request2.reload).to be_denied

      expect(request1.deny(user)).to be_truthy
      expect(roster.on_roster?(user)).to be true
      expect(request1.reload).to be_denied
    end

    it 'handles roster size above maximum' do
      pending 'Issue #267'

      roster = create(:league_roster, player_count: 3)
      roster.league.update!(min_players: 1, max_players: 2)
      user = roster.users.first

      request = create(:league_roster_transfer_request, roster: roster, user: user, is_joining: false)

      expect(request.deny(user)).to be_truthy
      expect(roster.on_roster?(user)).to be true
      expect(request.reload).to be_denied
    end
  end

  context 'validation' do
    describe '#unique_within_league_check' do
      let(:division) { create(:league_division) }
      let(:roster) { create(:league_roster, division: division) }
      let(:roster2) { create(:league_roster, division: division) }
      let(:user) { create(:user) }

      it 'validates unique within league' do
        request = build(:league_roster_transfer_request, propagate: true, roster: roster, user: user)
        expect(request).to be_valid
        expect(build(:league_roster_transfer_request, propagate: true, roster: roster)).to be_valid
        request.save!
        expect(build(:league_roster_transfer_request, propagate: true, roster: roster2,
                                                      user: user)).to be_invalid
        expect(build(:league_roster_transfer_request, propagate: true, roster: roster)).to be_valid
      end
    end

    describe '#on_team_check' do
      let(:roster) { create(:league_roster) }
      let(:user) { create(:user) }

      it 'validates when joining' do
        expect(build(:league_roster_transfer_request, roster: roster, user: user)).to be_invalid
        roster.team.add_player!(user)
        expect(build(:league_roster_transfer_request, roster: roster, user: user)).to be_valid
      end

      it "doesn't validate when leaving" do
        roster.add_player!(user)

        expect(build(:league_roster_transfer_request, roster: roster, user: user,
                                                      is_joining: false)).to be_valid
        roster.team.add_player!(user)
        expect(build(:league_roster_transfer_request, roster: roster, user: user,
                                                      is_joining: false)).to be_valid
      end
    end

    describe '#on_roster_check' do
      let(:roster) { create(:league_roster) }
      let(:user) { create(:user) }

      it 'validates when joining' do
        roster.team.add_player!(user)

        expect(build(:league_roster_transfer_request, roster: roster, user: user)).to be_valid
        roster.add_player!(user)
        expect(build(:league_roster_transfer_request, roster: roster, user: user)).to be_invalid
      end

      it 'validates on roster' do
        expect(build(:league_roster_transfer_request, roster: roster, user: user, is_joining: false)).to be_invalid
        roster.add_player!(user)
        expect(build(:league_roster_transfer_request, roster: roster, user: user, is_joining: false)).to be_valid
      end
    end

    describe '#active_roster_check' do
      let(:roster) { create(:league_roster, disbanded: true) }
      let(:user) { create(:user) }

      it 'validates when joining' do
        roster.team.add_player!(user)

        expect(build(:league_roster_transfer_request, roster: roster, user: user)).to be_invalid
      end

      it 'validates when leaving' do
        roster.add_player!(user)

        expect(build(:league_roster_transfer_request, roster: roster, user: user, is_joining: false)).to be_invalid
      end

      it "doesn't validate for transfer" do
        roster2 = create(:league_roster)
        roster2.team.add_player!(user)
        roster.add_player!(user)

        expect(build(:league_roster_transfer_request, roster: roster2, user: user)).to be_valid
      end
    end

    describe '#league_permissions_check' do
      let(:roster) { create(:league_roster) }
      let(:user) { create(:user) }

      it 'validates when joining' do
        roster.team.add_player!(user)
        user.ban(:use, :leagues)

        expect(build(:league_roster_transfer_request, roster: roster, user: user)).to be_invalid
      end

      it "doesn't validate when leaving" do
        roster.add_player!(user)
        user.ban(:use, :leagues)

        expect(build(:league_roster_transfer_request, roster: roster, user: user, is_joining: false)).to be_valid
      end
    end

    describe '#roster_size_limits_check' do
      let(:roster) { create(:league_roster, player_count: 2) }
      let(:league) { roster.league }

      context 'when joining' do
        it 'validates at maximum' do
          league.update!(min_players: 1, max_players: 2)

          expect(build(:league_roster_transfer_request, roster: roster, propagate: true)).to be_invalid
        end

        it 'validates with tentative size' do
          league.update!(min_players: 1, max_players: 3)

          create(:league_roster_transfer_request, roster: roster, propagate: true)

          expect(build(:league_roster_transfer_request, roster: roster, propagate: true)).to be_invalid
        end

        it 'validates with complex tentative size' do
          league.update!(min_players: 1, max_players: 5)

          3.times do
            create(:league_roster_transfer_request, roster: roster, propagate: true)
          end

          roster.users.each do |user|
            create(:league_roster_transfer_request, roster: roster, user: user, is_joining: false)
          end

          2.times do
            create(:league_roster_transfer_request, roster: roster, propagate: true)
          end

          expect(build(:league_roster_transfer_request, roster: roster, propagate: true)).to be_invalid
        end

        it 'validates when below minimum' do
          league.update!(min_players: 3, max_players: 6)

          expect(build(:league_roster_transfer_request, roster: roster, propagate: true)).to be_valid
        end
      end

      context 'when leaving' do
        let(:user) { roster.users.first }

        it 'validates at minimum' do
          league.update!(min_players: 2, max_players: 3)

          expect(build(:league_roster_transfer_request, roster: roster, user: user, is_joining: false)).to be_invalid
        end

        it 'validates with tentative size' do
          league.update!(min_players: 1, max_players: 3)

          user2 = roster.users.second
          create(:league_roster_transfer_request, roster: roster, user: user2, is_joining: false)

          expect(build(:league_roster_transfer_request, roster: roster, user: user, is_joining: false)).to be_invalid
        end

        it 'validates when above maximum' do
          league.update!(min_players: 1, max_players: 1)

          expect(build(:league_roster_transfer_request, roster: roster, user: user, is_joining: false)).to be_valid
        end
      end
    end

    describe '#leaving_roster_size_limits_check' do
      let(:roster) { create(:league_roster, player_count: 2) }
      let(:league) { roster.league }
      let(:roster2) { create(:league_roster, player_count: 2, division: roster.division) }
      let(:user) { roster.users.first }

      it 'validates at minimum' do
        league.update!(min_players: 2, max_players: 3)
        roster2.team.add_player!(user)

        expect(build(:league_roster_transfer_request, roster: roster2, user: user, is_joining: true)).to be_invalid
      end

      it 'validates when above maximum' do
        league.update!(min_players: 1, max_players: 3)
        2.times { roster.add_player!(create(:user)) }
        roster2.team.add_player!(user)

        expect(build(:league_roster_transfer_request, roster: roster2, user: user, is_joining: true)).to be_valid
      end

      it 'validates with tentative size' do
        league.update!(min_players: 2, max_players: 3)
        roster2.team.add_player!(user)

        create(:league_roster_transfer_request, roster: roster, propagate: true)

        expect(build(:league_roster_transfer_request, roster: roster2, user: user, is_joining: true)).to be_valid
      end
    end
  end
end
