require 'rails_helper'

describe User::Title do
  it { should belong_to(:user) }
  it { should_not allow_value(nil).for(:user) }

  it { should belong_to(:league) }
  it { should allow_value(nil).for(:roster) }

  it { should belong_to(:roster).class_name('League::Roster') }
  it { should allow_value(nil).for(:roster) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }
end
