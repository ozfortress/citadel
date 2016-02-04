require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe Transfer do
  before { create(:transfer) }

  it { should belong_to(:team) }
  it { should belong_to(:user) }

  it { should validate_presence_of(:team) }
  it { should validate_presence_of(:user) }
end
