require 'rails_helper'

describe League::Tiebreaker do
  before(:all) { create(:league_tiebreaker) }

  it { should belong_to(:league) }

  it { should define_enum_for(:kind) }
end
