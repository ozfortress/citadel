require 'rails_helper'

describe League::Schedulers::Weekly do
  before(:all) { create(:league_schedulers_weekly) }

  it { should belong_to(:league) }
  it { should_not allow_value(nil).for(:league) }

  it { should define_enum_for(:start_of_week).with(Date::DAYNAMES) }

  it { should validate_presence_of(:minimum_selected) }
  it { should validate_numericality_of(:minimum_selected).is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:days) }

  it 'validates days length' do
    expect(build(:league_schedulers_weekly, days: Array.new(6, true))).to be_invalid
    expect(build(:league_schedulers_weekly, days: Array.new(8, true))).to be_invalid
    expect(build(:league_schedulers_weekly, days: Array.new(7, true))).to be_valid
  end

  it 'validates minimum' do
    days = Array.new(5, true) + Array.new(2, false)
    expect(build(:league_schedulers_weekly, days: days, minimum_selected: 0)).to be_valid
    expect(build(:league_schedulers_weekly, days: days, minimum_selected: 5)).to be_valid
    expect(build(:league_schedulers_weekly, days: days, minimum_selected: 6)).to be_invalid
    expect(build(:league_schedulers_weekly, days: days, minimum_selected: 7)).to be_invalid
  end
end
