require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe CompetitionRosterComment do
  before { create(:competition_roster_comment) }

  it { should belong_to(:user) }
  it { should belong_to(:roster).class_name('CompetitionRoster') }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:roster) }
  it { should validate_presence_of(:content) }
end
