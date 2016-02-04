require 'rails_helper'

describe CompetitionTransfer do
  before { create(:competition_transfer) }

  it { should belong_to(:competition_roster) }
  it { should belong_to(:user) }
end
