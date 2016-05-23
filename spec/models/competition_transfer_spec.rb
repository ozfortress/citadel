require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe CompetitionTransfer do
  before { create(:competition_transfer) }

  it { should belong_to(:roster) }
  it { should belong_to(:user) }

  it { should validate_presence_of(:roster) }
  it { should validate_presence_of(:user) }

  it "doesn't allow a player to enter the same league twice" do
    comp = create(:competition)
    div1 = create(:division, competition: comp)
    div2 = create(:division, competition: comp)
    roster1 = create(:competition_roster, division: div1)
    roster2 = create(:competition_roster, division: div2)
    user = create(:user)
    roster1.team.add_player!(user)
    roster1.add_player!(user)
    roster2.team.add_player!(user)

    expect(build(:competition_transfer, roster: roster2, user: user,
                                        is_joining: true)).to be_invalid
  end
end
