require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe Format do
  before { Format.first || create(:format) }

  it { should belong_to(:game) }
  it { should have_many(:competitions) }

  it { should validate_presence_of(:game) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(128) }

  it { should validate_presence_of(:description) }

  it { should validate_presence_of(:player_count) }
  it { should validate_numericality_of(:player_count).is_greater_than(0) }
  it { should validate_numericality_of(:player_count).is_less_than_or_equal_to(16) }
end
