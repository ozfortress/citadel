require 'rails_helper'

describe Team::Invite do
  let!(:invite) { create(:team_invite) }

  it { should belong_to(:user) }
  # it { should validate_uniqueness_of(:user).scoped_to(:team) }

  it { should belong_to(:team) }
end
