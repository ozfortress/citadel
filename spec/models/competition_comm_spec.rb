require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe CompetitionComm do
  before { create(:competition_comm) }

  it { should belong_to(:user) }
  it { should belong_to(:match).class_name('CompetitionMatch') }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:match) }
  it { should validate_presence_of(:content) }
end
