require 'rails_helper'

describe League do
  before(:all) { create(:league) }

  it { should belong_to(:format) }
  it { should_not allow_value(nil).for(:format) }

  it { should have_many(:divisions).dependent(:destroy) }
  it { should accept_nested_attributes_for(:divisions).allow_destroy(true) }

  it { should have_many(:tiebreakers).dependent(:destroy) }
  it { should accept_nested_attributes_for(:tiebreakers).allow_destroy(true) }

  it { should have_many(:pooled_maps).dependent(:destroy) }
  it { should accept_nested_attributes_for(:pooled_maps).allow_destroy(true) }

  it { should have_many(:titles) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }

  it { should validate_presence_of(:description) }

  it { should define_enum_for(:status).with([:hidden, :running, :completed]) }

  it { should validate_presence_of(:min_players) }
  it { should validate_numericality_of(:min_players).is_greater_than(0) }

  it { should validate_presence_of(:max_players) }
  it { should validate_numericality_of(:max_players).is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:points_per_round_win) }
  it { should validate_numericality_of(:points_per_round_win).only_integer }

  it { should validate_presence_of(:points_per_round_draw) }
  it { should validate_numericality_of(:points_per_round_draw).only_integer }

  it { should validate_presence_of(:points_per_round_loss) }
  it { should validate_numericality_of(:points_per_round_loss).only_integer }

  it { should validate_presence_of(:points_per_match_win) }
  it { should validate_numericality_of(:points_per_match_win).only_integer }

  it { should validate_presence_of(:points_per_match_draw) }
  it { should validate_numericality_of(:points_per_match_draw).only_integer }

  it { should validate_presence_of(:points_per_match_loss) }
  it { should validate_numericality_of(:points_per_match_loss).only_integer }

  it { should define_enum_for(:schedule).with([:manual, :weeklies]) }

  it { should have_one(:weekly_scheduler).class_name('League::Schedulers::Weekly') }

  it 'validates max_players >= min_players' do
    expect(build(:league, min_players: 2, max_players: 2)).to be_valid
    expect(build(:league, min_players: 2, max_players: 3)).to be_valid
    expect(build(:league, min_players: 2, max_players: 1)).to be_invalid
  end

  it 'validates max_players == 0 is always valid' do
    expect(build(:league, min_players: 1, max_players: 0)).to be_valid
    expect(build(:league, min_players: 0, max_players: 0)).to be_invalid
  end

  it 'validates it has a scheduler' do
    league = build(:league, schedule: :weeklies)
    expect(league).to be_invalid
    league = build(:league, schedule: :weeklies)
    league.weekly_scheduler = build(:league_schedulers_weekly, league: league)
    expect(league).to be_valid
  end

  describe '#map_pool' do
    it 'returns all maps with no pooled maps' do
      league = create(:league)
      map = create(:map)

      expect(league.map_pool).to eq([map])
    end

    it 'returns pooled maps' do
      league = create(:league)
      pooled_map = create(:league_pooled_map, league: league)

      expect(league.map_pool).to eq([pooled_map.map])
    end
  end
end
