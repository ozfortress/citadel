require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe League::Roster::Comment do
  before { create(:league_roster_comment) }

  it { should belong_to(:user) }
  it { should_not allow_value(nil).for(:user) }

  it { should belong_to(:roster).class_name('League::Roster') }
  it { should_not allow_value(nil).for(:roster) }

  it { should validate_presence_of(:content) }
end
