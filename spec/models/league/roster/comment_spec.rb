require 'rails_helper'

describe League::Roster::Comment do
  before(:all) { create(:league_roster_comment) }

  it { should belong_to(:created_by) }
  it { should_not allow_value(nil).for(:created_by) }

  it { should belong_to(:roster).class_name('League::Roster') }
  it { should_not allow_value(nil).for(:roster) }

  it { should validate_presence_of(:content) }
end
