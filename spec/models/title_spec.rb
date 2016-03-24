require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe Title do
  it { should belong_to(:user) }
  it { should belong_to(:competition) }
  it { should belong_to(:competition_roster) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }
end
