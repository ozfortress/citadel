require 'rails_helper'

describe League::Division do
  before { create(:league_division) }

  it { should belong_to(:league) }

  it { should validate_presence_of(:league) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }
end
