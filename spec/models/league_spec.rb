require 'rails_helper'

describe League do
  before { create(:league) }

  it { should belong_to(:format) }
  it { should_not allow_value(nil).for(:format) }

  it { should have_many(:divisions) }
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

  it 'validates max_players >= min_players' do
    expect(build(:league, min_players: 2, max_players: 2)).to be_valid
    expect(build(:league, min_players: 2, max_players: 3)).to be_valid
    expect(build(:league, min_players: 2, max_players: 1)).not_to be_valid
  end

  it 'validates max_players == 0 is always valid' do
    expect(build(:league, min_players: 1, max_players: 0)).to be_valid
    expect(build(:league, min_players: 0, max_players: 0)).not_to be_valid
  end
end
