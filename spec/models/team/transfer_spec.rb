require 'rails_helper'

describe Team::Transfer do
  before { create(:team_transfer) }

  it { should belong_to(:team) }
  it { should_not allow_value(nil).for(:team) }

  it { should belong_to(:user) }
  it { should_not allow_value(nil).for(:user) }
end
