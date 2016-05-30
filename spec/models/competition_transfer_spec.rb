require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe CompetitionTransfer do
  before { create(:competition_transfer) }

  it { should belong_to(:roster) }
  it { should belong_to(:user) }

  it { should validate_presence_of(:roster) }
  it { should validate_presence_of(:user) }

  let(:comp) { create(:competition, signuppable: true) }
  let(:div) { create(:division, competition: comp) }

  it 'allows a player to join' do
    roster = create(:competition_roster, division: div)
    user = create(:user)
    roster.team.add_player!(user)

    transfer = build(:competition_transfer, roster: roster, user: user,
                                            is_joining: true, approved: true)
    expect(transfer).to be_valid
    expect(transfer.save).to be(true)
    expect(roster.on_roster?(user)).to be(true)
  end

  it 'allows a player to leave' do
    roster = create(:competition_roster, division: div)
    user = create(:user)
    roster.team.add_player!(user)
    roster.add_player!(user, approved: true)

    transfer = build(:competition_transfer, roster: roster, user: user,
                                            is_joining: false, approved: true)
    expect(transfer).to be_valid
    expect(transfer.save).to be(true)
    expect(roster.on_roster?(user)).to be(false)
  end

  it 'allows a player to transfer between roster' do
    comp = create(:competition)
    div1 = create(:division, competition: comp)
    div2 = create(:division, competition: comp)
    roster1 = create(:competition_roster, division: div1)
    roster2 = create(:competition_roster, division: div2)
    user = create(:user)
    roster1.team.add_player!(user)
    roster1.add_player!(user, approved: true)
    roster1.remove_player!(user, approved: true)
    roster2.team.add_player!(user)

    expect(build(:competition_transfer, roster: roster2, user: user,
                                        is_joining: true)).to be_valid
  end

  it "doesn't allow a player to enter the same league twice" do
    comp = create(:competition)
    div1 = create(:division, competition: comp)
    div2 = create(:division, competition: comp)
    roster1 = create(:competition_roster, division: div1)
    roster2 = create(:competition_roster, division: div2)
    user = create(:user)
    roster1.team.add_player!(user)
    roster1.add_player!(user, approved: true)
    roster2.team.add_player!(user)

    expect(build(:competition_transfer, roster: roster2, user: user,
                                        is_joining: true)).to be_invalid
  end

  it "doesn't allow a player to join a roster when they aren't on the team" do
    roster = create(:competition_roster)
    user = create(:user)

    expect(build(:competition_transfer, roster: roster, user: user,
                                        propagate_transfers: false,
                                        is_joining: true)).to be_invalid
  end

  it "doesn't allow a player to leave without being on the roster" do
    roster = create(:competition_roster)
    user = create(:user)
    roster.team.add_player!(user)

    expect(build(:competition_transfer, propagate_transfers: false, roster: roster,
                                        user: user, is_joining: false)).to be_invalid
  end

  it 'notifies player on creation for joining' do
    transfer = create(:competition_transfer, is_joining: true)

    expect(transfer.user.notifications).to_not be_empty
  end

  it 'notifies player on creation for leaving' do
    transfer = create(:competition_transfer, is_joining: false)

    expect(transfer.user.notifications).to_not be_empty
  end

  it 'notifies player on approval for joining' do
    transfer = create(:competition_transfer)
    user = transfer.user
    user.notifications.destroy_all

    transfer.update!(approved: true)

    expect(user.notifications).to_not be_empty
  end

  it 'notifies player on approval for leaving' do
    transfer = create(:competition_transfer, is_joining: false)
    user = transfer.user
    user.notifications.destroy_all

    transfer.update!(approved: true)

    expect(user.notifications).to_not be_empty
  end

  it 'notifies captains on approval' do
    transfer = create(:competition_transfer)
    cap1 = create(:user)
    cap1.grant(:edit, transfer.team)
    cap2 = create(:user)
    cap2.grant(:edit, transfer.team)

    transfer.update!(approved: true)

    expect(cap1.notifications).to_not be_empty
    expect(cap2.notifications).to_not be_empty
  end

  it 'notifies player on denial for joining' do
    transfer = create(:competition_transfer)
    user = transfer.user
    user.notifications.destroy_all

    transfer.destroy!

    expect(user.notifications).to_not be_empty
  end

  it 'notifies player on denial for leaving' do
    transfer = create(:competition_transfer, is_joining: false)
    user = transfer.user
    user.notifications.destroy_all

    transfer.destroy!

    expect(user.notifications).to_not be_empty
  end

  it 'notifies captains on denial' do
    transfer = create(:competition_transfer)
    cap1 = create(:user)
    cap1.grant(:edit, transfer.team)
    cap2 = create(:user)
    cap2.grant(:edit, transfer.team)

    transfer.destroy!

    expect(cap1.notifications).to_not be_empty
    expect(cap2.notifications).to_not be_empty
  end
end
