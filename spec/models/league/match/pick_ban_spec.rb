require 'rails_helper'

describe League::Match::PickBan do
  it { should belong_to(:match).class_name('League::Match') }
  it { should_not allow_value(nil).for(:match) }

  it { should belong_to(:picked_by).class_name('User') }
  it { should allow_value(nil).for(:picked_by) }

  it { should belong_to(:map).class_name('Map') }
  it { should allow_value(nil).for(:map) }

  it { should define_enum_for(:kind).with([:pick, :ban]) }

  it { should define_enum_for(:team).with([:home_team, :away_team]) }

  describe '#map_and_pick_present' do
    let(:map) { build(:map) }
    let(:user) { build(:user) }

    it 'validates successfully' do
      pick_ban = build(:league_match_pick_ban, map: nil, picked_by: nil)
      expect(pick_ban).to be_valid
      pick_ban.assign_attributes(map: map, picked_by: user)
      expect(pick_ban).to be_valid

      pick_ban.assign_attributes(map: map, picked_by: nil)
      expect(pick_ban).to be_invalid
      pick_ban.assign_attributes(map: nil, picked_by: user)
      expect(pick_ban).to be_invalid
    end
  end

  describe '#submit' do
    let(:map) { create(:map) }
    let(:user) { create(:user) }

    it 'successfully bans a map' do
      ban = create(:league_match_pick_ban, kind: :ban)

      expect(ban.submit(user, map)).to be(true)
      ban.match.reload
      expect(ban.match.rounds).to be_empty
      expect(ban.match.map_pool).to_not include(map)
    end

    it 'successfully picks a map' do
      pick = create(:league_match_pick_ban, kind: :pick)

      expect(pick.submit(user, map)).to be(true)
      pick.match.reload
      expect(pick.match.rounds).to_not be_empty
      expect(pick.match.map_pool).to_not include(map)
    end
  end

  describe '#defer!' do
    let(:map) { create(:map) }
    let(:user) { create(:user) }
    let(:match) { create(:league_match) }

    before do
      @picked = create_list(:league_match_pick_ban, 2, match: match, picked_by: user,
                                                       map: map, team: :home_team)
      @deferrable = create(:league_match_pick_ban, match: match, deferrable: true, team: :away_team)
      @pending = create_list(:league_match_pick_ban, 2, match: match, team: :home_team)
    end

    it 'successfully defers' do
      expect(@deferrable.defer!).to be(true)

      @picked.each do |pick_ban|
        expect(pick_ban.reload.home_team?).to be(true)
      end

      @deferrable.reload
      expect(@deferrable.home_team?).to be(true)
      expect(@deferrable.pending?).to be(true)
      expect(@deferrable.deferrable?).to be(false)

      @pending.each do |pick_ban|
        expect(pick_ban.reload.away_team?).to be(true)
      end
    end
  end
end
