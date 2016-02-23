require 'rails_helper'
require 'support/factory_girl'

describe CompetitionRoster do
  before { create(:competition_roster) }

  it { should belong_to(:team) }
  it { should belong_to(:division) }
  it { should have_many(:transfers).class_name('CompetitionTransfer') }

  it { should validate_presence_of(:team) }
  it { should validate_uniqueness_of(:team).scoped_to(:division_id) }
  it { should validate_presence_of(:division) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:division_id) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }

  it { should allow_value('').for(:description) }
  it { should validate_length_of(:description).is_at_least(0) }
end
