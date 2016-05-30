require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe Transfer do
  before { create(:transfer) }

  it { should belong_to(:team) }
  it { should belong_to(:user) }

  it { should validate_presence_of(:team) }
  it { should validate_presence_of(:user) }

  it 'notifies captains on user leaving' do
    team = create(:team)
    cap1 = create(:user)
    cap1.grant(:edit, team)
    cap2 = create(:user)
    cap2.grant(:edit, team)

    create(:transfer, team: team, user: create(:user), is_joining: false)

    expect(cap1.notifications).to_not be_empty
    expect(cap2.notifications).to_not be_empty
  end
end
