require 'rails_helper'

describe Competition do
  before { create(:competition) }

  it { should belong_to(:format) }
  it { should have_many(:divisions) }

  it { should validate_presence_of(:format) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }

  it { should validate_presence_of(:description) }

  it { should validate_presence_of(:min_players) }
  it { should validate_numericality_of(:min_players).is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:max_players) }
  it { should validate_numericality_of(:max_players).is_greater_than_or_equal_to(0) }
end
