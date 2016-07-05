require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe CompetitionTransfer do
  before { create(:competition_transfer) }

  it { should belong_to(:roster) }
  it { should belong_to(:user) }

  it { should validate_presence_of(:roster) }
  it { should validate_presence_of(:user) }

  let(:comp) { create(:competition) }
  let(:div) { create(:division, competition: comp) }
  let(:div2) { create(:division, competition: comp) }

  shared_examples 'common' do
    it "doesn't allow a player to join a roster when they aren't on the team" do
      roster.team.remove_player!(user)

      expect(build(:competition_transfer, roster: roster, user: user,
                                          propagate_transfers: false,
                                          is_joining: true)).to be_invalid
    end

    it "doesn't allow a player to leave without being on the roster" do
      expect(build(:competition_transfer, propagate_transfers: false, roster: roster,
                                          user: user, is_joining: false)).to be_invalid
    end
  end

  context 'pending roster' do
    let(:roster) { create(:competition_roster, division: div, approved: false) }
    let(:user) { create(:user) }

    before do
      roster.team.add_player!(user)
    end

    it 'auto-approves in transfers' do
      transfer = roster.transfers.new(user: user, is_joining: true)

      expect(transfer).to be_valid
      expect(transfer.approved).to be(true)
    end

    it 'auto-approves out transfers' do
      roster.add_player!(user)

      transfer = roster.transfers.new(user: user, is_joining: false)

      expect(transfer).to be_valid
      expect(transfer.approved).to be(true)
    end

    it "doesn't auto-approve transfers between rosters" do
      roster2 = create(:competition_roster, division: div2)
      roster.team.add_player!(user)
      roster.add_player!(user, approved: true)
      roster2.team.add_player!(user)

      transfer = build(:competition_transfer, roster: roster2, user: user, is_joining: true)

      expect(transfer).to be_valid
      expect(transfer.approved).to be(false)
    end

    include_examples 'common'
  end

  context 'approved roster' do
    let(:roster) { create(:competition_roster, division: div) }
    let(:user) { create(:user) }

    before do
      roster.team.add_player!(user)
    end

    it 'allows a player to join' do
      transfer = build(:competition_transfer, roster: roster, user: user,
                                              is_joining: true, approved: true)

      expect(transfer).to be_valid
      expect(transfer.save).to be(true)
      expect(roster.on_roster?(user)).to be(true)
    end

    it 'allows a player to leave' do
      roster.add_player!(user, approved: true)

      transfer = build(:competition_transfer, roster: roster, user: user,
                                              is_joining: false, approved: true)

      expect(transfer).to be_valid
      expect(transfer.save).to be(true)
      expect(roster.on_roster?(user)).to be(false)
    end

    it 'allows a player to transfer between rosters' do
      roster2 = create(:competition_roster, division: div2)
      roster2.team.add_player!(user)

      transfer = create(:competition_transfer, roster: roster2, user: user,
                                               is_joining: true, approved: false)
      transfer.update!(approved: true)

      expect(roster.on_roster?(user)).to be(false)
      expect(roster2.on_roster?(user)).to be(true)
    end

    include_examples 'common'
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
