require 'rails_helper'

describe League::Roster::Transfer do
  before(:all) { create(:league_roster_transfer) }

  it { should belong_to(:roster) }
  it { should_not allow_value(nil).for(:roster) }

  it { should belong_to(:user) }
  it { should_not allow_value(nil).for(:user) }

  it 'notifies player on creation for joining' do
    transfer = create(:league_roster_transfer, is_joining: true)

    expect(transfer.user.notifications).to_not be_empty
  end

  it 'notifies player on creation for leaving' do
    transfer = create(:league_roster_transfer, is_joining: false)

    expect(transfer.user.notifications).to_not be_empty
  end

  it 'notifies player on approval for joining' do
    transfer = create(:league_roster_transfer)
    user = transfer.user
    user.notifications.destroy_all

    transfer.update!(approved: true)

    expect(user.notifications).to_not be_empty
  end

  it 'notifies player on approval for leaving' do
    transfer = create(:league_roster_transfer, is_joining: false)
    user = transfer.user
    user.notifications.destroy_all

    transfer.update!(approved: true)

    expect(user.notifications).to_not be_empty
  end

  it 'notifies captains on approval' do
    transfer = create(:league_roster_transfer)
    cap1 = create(:user)
    cap1.grant(:edit, transfer.team)
    cap2 = create(:user)
    cap2.grant(:edit, transfer.team)

    transfer.update!(approved: true)

    expect(cap1.notifications).to_not be_empty
    expect(cap2.notifications).to_not be_empty
  end

  it 'notifies player on denial for joining' do
    transfer = create(:league_roster_transfer)
    user = transfer.user
    user.notifications.destroy_all

    transfer.destroy!

    expect(user.notifications).to_not be_empty
  end

  it 'notifies player on denial for leaving' do
    transfer = create(:league_roster_transfer, is_joining: false)
    user = transfer.user
    user.notifications.destroy_all

    transfer.destroy!

    expect(user.notifications).to_not be_empty
  end

  it 'notifies captains on denial' do
    transfer = create(:league_roster_transfer)
    cap1 = create(:user)
    cap1.grant(:edit, transfer.team)
    cap2 = create(:user)
    cap2.grant(:edit, transfer.team)

    transfer.destroy!

    expect(cap1.notifications).to_not be_empty
    expect(cap2.notifications).to_not be_empty
  end
end
