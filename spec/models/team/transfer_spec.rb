require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe Team::Transfer do
  before { create(:team_transfer) }

  it { should belong_to(:team) }
  it { should_not allow_value(nil).for(:team) }

  it { should belong_to(:user) }
  it { should_not allow_value(nil).for(:user) }

  it 'notifies captains on user leaving' do
    team = create(:team)
    cap1 = create(:user)
    cap1.grant(:edit, team)
    cap2 = create(:user)
    cap2.grant(:edit, team)

    create(:team_transfer, team: team, user: create(:user), is_joining: false)

    expect(cap1.notifications).to_not be_empty
    expect(cap2.notifications).to_not be_empty
  end
end
