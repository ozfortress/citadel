require 'rails_helper'

describe League::Roster::TransferRequest do
  before(:all) { create(:league_roster_transfer_request, propagate: true) }

  it { should belong_to(:roster) }
  it { should belong_to(:user) }

  it { should define_enum_for(:status).with([:pending, :approved, :denied]) }

  describe '#approve' do
    it 'succeeds when joining' do
      request = create(:league_roster_transfer_request, propagate: true)
      user = request.user
      roster = request.roster
      roster2 = create(:league_roster, division: request.division)
      roster2.add_player!(request.user)

      expect(request.approve).to be_truthy
      expect(roster.on_roster?(user)).to be(true)
      expect(roster2.on_roster?(user)).to be(false)
      expect(request.reload).to be_approved
    end

    it 'succeeds when leaving' do
      roster = create(:league_roster, player_count: 3)
      user = roster.users.first
      request = create(:league_roster_transfer_request,
                       roster: roster, user: user, is_joining: false)

      expect(request.approve).to be_truthy
      expect(roster.on_roster?(user)).to be(false)
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

      expect(request.deny).to be_truthy
      expect(roster.on_roster?(user)).to be(false)
      expect(roster2.on_roster?(user)).to be(true)
      expect(request.reload).to be_denied
    end

    it 'succeeds when leaving' do
      roster = create(:league_roster, player_count: 3)
      user = roster.users.first
      request = create(:league_roster_transfer_request,
                       roster: roster, user: user, is_joining: false)

      expect(request.deny).to be_truthy
      expect(roster.on_roster?(user)).to be(true)
      expect(request.reload).to be_denied
    end
  end

  it 'validates unique within league' do
    roster = create(:league_roster)
    roster2 = create(:league_roster, division: roster.division)
    user = create(:user)

    request = build(:league_roster_transfer_request, propagate: true, roster: roster, user: user)
    expect(request).to be_valid
    expect(build(:league_roster_transfer_request, propagate: true, roster: roster)).to be_valid
    request.save!
    expect(build(:league_roster_transfer_request, propagate: true, roster: roster2,
                                                  user: user)).to be_invalid
    expect(build(:league_roster_transfer_request, propagate: true, roster: roster)).to be_valid
  end

  it 'validates on team' do
    roster = create(:league_roster)
    user = create(:user)

    expect(build(:league_roster_transfer_request, roster: roster, user: user)).to be_invalid
    roster.team.add_player!(user)
    expect(build(:league_roster_transfer_request, roster: roster, user: user)).to be_valid
  end

  it 'validates on roster' do
    roster = create(:league_roster)
    user = create(:user)

    expect(build(:league_roster_transfer_request, roster: roster, user: user,
                                                  is_joining: false)).to be_invalid
    roster.add_player!(user)
    expect(build(:league_roster_transfer_request, roster: roster, user: user,
                                                  is_joining: false)).to be_valid
  end

  context 'validates within roster size' do
    let(:roster) { create(:league_roster, player_count: 2) }

    it 'when joining' do
      roster.league.update!(min_players: 2, max_players: 2)

      expect(build(:league_roster_transfer_request, roster: roster, propagate: true)).to be_invalid
    end

    it 'when leaving' do
      roster.league.update!(min_players: 2, max_players: 2)

      user = roster.users.first
      expect(build(:league_roster_transfer_request, roster: roster, user: user,
                                                    is_joining: false)).to be_invalid
    end

    it 'when transferring' do
      roster.league.update!(min_players: 1, max_players: 2)
      other_roster = create(:league_roster, player_count: 2, division: roster.division)

      user = roster.users.first
      expect(build(:league_roster_transfer_request, roster: roster, user: user,
                                                    is_joining: false)).to be_valid
      expect(build(:league_roster_transfer_request, roster: other_roster, user: user,
                                                    is_joining: true)).to be_invalid
    end

    context 'for overflown roster' do
      before do
        roster.league.update!(max_players: 1)
      end

      it 'when joining' do
        expect(build(:league_roster_transfer_request,
                     roster: roster, propagate: true)).to be_invalid
      end

      it 'when leaving' do
        user = roster.users.first
        expect(build(:league_roster_transfer_request,
                     roster: roster, user: user, is_joining: false)).to be_valid
      end
    end

    context 'for underflown roster' do
      before do
        roster.league.update!(min_players: 5)
      end

      it 'when joining' do
        expect(build(:league_roster_transfer_request,
                     roster: roster, propagate: true)).to be_valid
      end

      it 'when leaving' do
        user = roster.users.first
        expect(build(:league_roster_transfer_request,
                     roster: roster, user: user, is_joining: false)).to be_invalid
      end
    end
  end
end
