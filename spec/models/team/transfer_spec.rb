require 'rails_helper'

describe Team::Transfer do
  before { create(:team_transfer) }

  it { should belong_to(:team) }

  it { should belong_to(:user) }
end
