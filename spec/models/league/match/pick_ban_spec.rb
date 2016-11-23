require 'rails_helper'

describe League::Match::PickBan do
  it { should belong_to(:match).class_name('League::Match') }
  it { should_not allow_value(nil).for(:match) }

  it { should belong_to(:picked_by).class_name('User') }
  it { should allow_value(nil).for(:picked_by) }

  it { should define_enum_for(:kind).with([:pick, :ban]) }

  it { should define_enum_for(:team).with([:home_team, :away_team]) }
end
