require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe TeamInvite do
  before { create(:team_invite) }

  it { should belong_to(:user) }
  it { should belong_to(:team) }
end
