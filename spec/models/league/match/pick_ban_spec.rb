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
      expect(build(:league_match_pick_ban, map: nil, picked_by: nil)).to be_valid
      expect(build(:league_match_pick_ban, map: map, picked_by: user)).to be_valid

      expect(build(:league_match_pick_ban, map: map, picked_by: nil)).to be_invalid
      expect(build(:league_match_pick_ban, map: nil, picked_by: user)).to be_invalid
    end
  end
end
