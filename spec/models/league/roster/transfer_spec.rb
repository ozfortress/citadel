require 'rails_helper'

describe League::Roster::Transfer do
  before(:all) { create(:league_roster_transfer) }

  it { should belong_to(:roster) }

  it { should belong_to(:user) }
end
