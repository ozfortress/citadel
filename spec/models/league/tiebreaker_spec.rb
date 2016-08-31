require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe League::Tiebreaker do
  before { create(:league_tiebreaker) }

  it { should belong_to(:league) }
  it { should_not allow_value(nil).for(:league) }

  it { should define_enum_for(:kind) }
end
