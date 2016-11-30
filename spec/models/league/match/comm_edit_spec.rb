require 'rails_helper'

describe League::Match::CommEdit do
  before(:all) { create(:league_match_comm_edit) }

  it { should belong_to(:comm).class_name('League::Match::Comm') }
  it { should_not allow_value(nil).for(:comm) }

  it { should belong_to(:user).class_name('User') }
  it { should_not allow_value(nil).for(:user) }

  it { should validate_presence_of(:content) }
end
