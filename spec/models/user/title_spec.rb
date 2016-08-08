require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe User::Title do
  it { should belong_to(:user) }
  it { should belong_to(:league) }
  it { should belong_to(:roster).class_name('League::Roster') }

  it { should validate_presence_of(:user) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }
end
