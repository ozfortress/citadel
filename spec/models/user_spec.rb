require 'rails_helper'

describe User do
  before(:all) { create(:user) }

  it { should have_many(:roster_transfers).class_name('League::Roster::Transfer') }
  it { should have_many(:titles) }
  it { should have_many(:names).class_name('User::NameChange') }
  it { should have_many(:notifications) }
  it { should have_many(:forums_subscriptions).class_name('Forums::Subscription') }

  it { should have_many(:team_players).class_name('Team::Player') }
  it { should have_many(:teams).through(:team_players) }
  it { should have_many(:team_invites).class_name('Team::Invite') }
  it { should have_many(:team_transfers).class_name('Team::Transfer') }

  it { should have_many(:roster_players).class_name('League::Roster::Player') }
  it { should have_many(:rosters).through(:team_players) }
  it { should have_many(:roster_transfers).class_name('League::Roster::Transfer') }
  it { should have_many(:roster_transfer_requests).class_name('League::Roster::TransferRequest') }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }

  it { should validate_presence_of(:steam_id) }
  it { should validate_uniqueness_of(:steam_id) }
  it { should validate_numericality_of(:steam_id).is_greater_than(0) }

  it { should allow_value('').for(:description) }
  it { should validate_length_of(:description).is_at_least(0) }

  it { should allow_value('').for(:email) }
  it { should allow_value('foo@bar.com').for(:email) }
  # Example from Wikipedia
  it { should allow_value('"v.(),:;<>[]\".V.\"v@\\ \"v\".u"@strange.com').for(:email) }
  it { should_not allow_value('foo').for(:email) }

  it 'creates proper steam profile links' do
    user = create(:user, name: 'Crock Facker', steam_id: '76561198037529561')

    expect(user.steam_profile_url).to eq('http://steamcommunity.com/profiles/76561198037529561')
  end

  it 'has teams' do
    user = create(:user)
    team = create(:team, name: 'A')
    team2 = create(:team, name: 'B')
    create(:team, name: 'C')

    team.add_player!(user)
    team2.add_player!(user)
    team2.remove_player!(user)

    expect(user.teams).to eq([team])
    expect(team.on_roster?(user)).to be(true)
  end

  it 'can be notified' do
    user = create(:user)
    expect(user.notifications).to eq([])

    notification = user.notify!('foo', '/bar')

    expect(notification).to be_persisted
    expect(user.notifications).to eq([notification])
    expect(user.notifications.unread).to eq([notification])
  end

  it 'has avatar' do
    image = File.open(Rails.root.join('spec/support/avatar.png'))
    expect(build(:user, avatar: image)).to be_valid
  end

  context 'Permissions' do
    describe 'Teams' do
      let(:team)       { create(:team) }
      let(:team2)      { create(:team) }
      let(:user)       { create(:user) }
      let(:leader)     { create(:user) }
      let(:leader2)    { create(:user) }
      let(:admin)      { create(:user) }
      let(:old_leader) { create(:user) }

      before do
        old_leader.grant(:edit, team)
        leader.grant(:edit, team)
        leader2.grant(:edit, team2)
        admin.grant(:edit, :teams)
        old_leader.revoke(:edit, team)
      end

      it "doesn't let normal users edit teams" do
        expect(user.can?(:edit, team)).to be(false)
      end

      it 'lets a team leader edit his team' do
        expect(leader.can?(:edit, team)).to be(true)
      end

      it "doesn't let a team leader edit other teams" do
        expect(leader.can?(:edit, team2)).to be(false)
      end

      it 'lets an admin edit any team' do
        expect(admin.can?(:edit, :teams))
      end

      it "doesn't let an old leader edit the team" do
        expect(old_leader.can?(:edit, team)).to be(false)
      end

      it 'lists the right people with permissions' do
        users = User.get_revokeable(:edit, team)
        admins = User.get_revokeable(:edit, :teams)

        expect(users).to eq([leader])
        expect(admins).to eq([admin])
      end
    end

    describe 'Meta' do
      let(:user)  { create(:user) }
      let(:admin) { create(:user) }
      let(:old)   { create(:user) }

      it "shouldn't let normal users edit meta" do
        expect(user.can?(:edit, :games)).to be(false)
      end

      it 'should let a admin edit meta' do
        admin.grant(:edit, :games)
        expect(admin.can?(:edit, :games)).to be(true)
      end

      it "shouldn't let an old admin edit meta" do
        old.grant(:edit, :games)
        old.revoke(:edit, :games)
        expect(old.can?(:edit, :games)).to be(false)
      end
    end
  end
end
