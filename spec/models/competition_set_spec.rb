require 'rails_helper'
require 'support/factory_girl'

describe CompetitionSet do
  before { create(:competition_set) }

  it { should belong_to(:map) }
  it { should belong_to(:match).class_name('CompetitionMatch') }

  it { should validate_presence_of(:map) }
  it { should validate_presence_of(:match) }

  it { should validate_presence_of(:home_team_score) }
  it { should validate_numericality_of(:home_team_score).is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:away_team_score) }
  it { should validate_numericality_of(:away_team_score).is_greater_than_or_equal_to(0) }
end
