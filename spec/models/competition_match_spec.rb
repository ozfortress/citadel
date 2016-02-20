require 'rails_helper'
require 'support/factory_girl'

describe CompetitionMatch do
  before { create(:competition_match) }

  it { should belong_to(:home_team).class_name('CompetitionRoster') }
  it { should belong_to(:away_team).class_name('CompetitionRoster') }
  it { should have_many(:sets).class_name('CompetitionSet') }

  it { should validate_presence_of(:home_team) }
  it { should validate_presence_of(:away_team) }
end
