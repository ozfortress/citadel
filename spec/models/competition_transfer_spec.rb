require 'rails_helper'

describe CompetitionTransfer do
  before { create(:competition_transfer) }

  it { should belong_to(:roster) }
  it { should belong_to(:user) }

  it { should validate_presence_of(:roster) }
  it { should validate_presence_of(:user) }
end
