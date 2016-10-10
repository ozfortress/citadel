require 'rails_helper'

describe League::Roster::TransferRequest do
  before(:all) { create(:league_roster_transfer_request, propagate: true) }

  it { should belong_to(:roster) }
  it { should belong_to(:user) }

  describe '#approve'

  describe '#deny'

  it 'validates unique within league'

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
  end
end
