require 'rails_helper'

describe League::Match::Comm do
  before(:all) { create(:league_match_comm) }

  it { should belong_to(:created_by) }
  it { should_not allow_value(nil).for(:created_by) }

  it { should belong_to(:match).class_name('League::Match') }
  it { should_not allow_value(nil).for(:match) }

  it { should have_many(:edits).class_name('League::Match::CommEdit') }

  it { should validate_presence_of(:content) }
  it { should validate_length_of(:content).is_at_least(2).is_at_most(1_000) }
end
