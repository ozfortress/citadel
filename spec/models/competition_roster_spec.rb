require 'rails_helper'
require 'support/factory_girl'

describe CompetitionRoster do
  before { create(:competition_roster) }

  it { should belong_to(:team) }
  it { should belong_to(:division) }
  it { should have_many(:transfers).class_name('CompetitionTransfer') }

  it { should validate_presence_of(:team) }
  it { should validate_presence_of(:division) }

  it { should validate_presence_of(:points) }
  it { should validate_numericality_of(:points).is_greater_than_or_equal_to(0) }
end
