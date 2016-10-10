require 'rails_helper'

describe League::Roster::Transfer do
  before(:all) { create(:league_roster_transfer) }

  it { should belong_to(:roster) }
  it { should_not allow_value(nil).for(:roster) }

  it { should belong_to(:user) }
  it { should_not allow_value(nil).for(:user) }
end
