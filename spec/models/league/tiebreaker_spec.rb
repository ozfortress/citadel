require 'rails_helper'

describe League::Tiebreaker do
  before { create(:league_tiebreaker) }

  it { should belong_to(:league) }
  it { should_not allow_value(nil).for(:league) }

  it { should define_enum_for(:kind) }
end
