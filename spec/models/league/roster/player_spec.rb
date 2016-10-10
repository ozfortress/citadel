require 'rails_helper'

describe League::Roster::Player do
  before(:all) { create(:league_roster_player) }

  it { should belong_to(:roster) }
  it { should belong_to(:user) }

  it 'validates unique within league' do
    roster = create(:league_roster)
    roster2 = create(:league_roster, division: roster.division)
    div2 = create(:league_division, league: roster.league)
    roster3 = create(:league_roster, division: div2)
    user = create(:user)

    expect(build(:league_roster_player, roster: roster, user: user)).to be_valid
    expect(build(:league_roster_player, roster: roster2, user: user)).to be_valid
    expect(build(:league_roster_player, roster: roster3, user: user)).to be_valid

    roster.add_player!(user)

    expect(build(:league_roster_player, roster: roster, user: user)).to be_invalid
    expect(build(:league_roster_player, roster: roster2, user: user)).to be_invalid
    expect(build(:league_roster_player, roster: roster3, user: user)).to be_invalid

    roster.remove_player!(user)

    expect(build(:league_roster_player, roster: roster, user: user)).to be_valid
    expect(build(:league_roster_player, roster: roster2, user: user)).to be_valid
    expect(build(:league_roster_player, roster: roster3, user: user)).to be_valid
  end

  it 'creates transfers on creation' do
    roster = create(:league_roster)
    count = roster.transfers.count

    player = create(:league_roster_player, roster: roster)

    expect(roster.transfers.count).to eq(count + 1)
    transfer = roster.transfers.first
    expect(transfer.user).to eq(player.user)
    expect(transfer.is_joining?).to be(true)
  end

  it 'creates transfers on destroy' do
    roster = create(:league_roster)
    player = create(:league_roster_player, roster: roster)
    count = roster.transfers.count

    player.destroy!

    expect(roster.transfers.count).to eq(count + 1)
    transfer = roster.transfers.first
    expect(transfer.user).to eq(player.user)
    expect(transfer.is_joining?).to be(false)
  end
end
