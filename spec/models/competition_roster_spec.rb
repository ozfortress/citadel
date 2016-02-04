require 'rails_helper'

describe CompetitionRoster do
  before { create(:competition_roster) }

  it { should belong_to(:team) }
  it { should belong_to(:competition) }
  it { should belong_to(:division) }
  it { should have_many(:transfers).class_name('CompetitionTransfer') }

  it { should validate_presence_of(:team) }
  it { should validate_presence_of(:competition) }
end
