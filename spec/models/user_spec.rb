require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe User do
  let!(:user) { create(:user) }

  it { should have_many(:team_invites) }
  it { should have_many(:transfers) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }

  it { should validate_presence_of(:steam_id) }
  it { should validate_uniqueness_of(:steam_id) }
  it { should validate_numericality_of(:steam_id).is_greater_than(0) }

  it { should allow_value('').for(:description) }
  it { should validate_length_of(:description).is_at_least(0) }

  it 'creates proper steam profile links' do
    user = create(:user, name: 'Crock Facker', steam_id: '76561198037529561')

    expect(user.steam_profile_url).to eq('http://steamcommunity.com/profiles/76561198037529561')
  end

  it 'has teams' do
    team = create(:team, name: 'A')
    team2 = create(:team, name: 'B')
    team3 = create(:team, name: 'C')

    team.add_player(user)
    team2.add_player(user)
    team2.remove_player(user)

    expect(user.teams).to eq([team])
  end

  describe 'Permissions' do
    describe 'Teams' do
      let(:team)       { create(:team, name: 'A') }
      let(:team2)      { create(:team, name: 'B') }
      let(:user)       { create(:user, name: 'A', steam_id: 1) }
      let(:leader)     { create(:user, name: 'B', steam_id: 2) }
      let(:leader2)    { create(:user, name: 'C', steam_id: 3) }
      let(:admin)      { create(:user, name: 'D', steam_id: 4) }
      let(:old_leader) { create(:user, name: 'E', steam_id: 5) }

      before do
        old_leader.grant(:edit, team)
        leader.grant(:edit, team)
        leader2.grant(:edit, team2)
        admin.grant(:edit, :teams)
        old_leader.revoke(:edit, team)
      end

      it "shouldn't let normal users edit teams" do
        expect(user.can?(:edit, team)).to be(false)
      end

      it 'should let a team leader edit his team' do
        expect(leader.can?(:edit, team)).to be(true)
      end

      it "shouldn't let a team leader edit other teams" do
        expect(leader.can?(:edit, team2)).to be(false)
      end

      it 'should let an admin edit any team' do
        expect(admin.can?(:edit, :teams))
      end

      it "shouldn't let an old leader edit the team" do
        expect(old_leader.can?(:edit, team)).to be(false)
      end

      it 'should list the right people with permissions' do
        users = User.get_revokeable(:edit, team)
        admins = User.get_revokeable(:edit, :teams)

        expect(users).to eq([leader])
        expect(admins).to eq([admin])
      end
    end

    describe 'Meta' do
      let(:user)  { create(:user, name: 'A', steam_id: 1) }
      let(:admin) { create(:user, name: 'B', steam_id: 2) }
      let(:old)   { create(:user, name: 'C', steam_id: 3) }

      before do
        admin.grant(:edit, :games)
        old.grant(:edit, :games)
        old.revoke(:edit, :games)
      end

      it "shouldn't let normal users edit meta" do
        expect(user.can?(:edit, :games)).to be(false)
      end

      it 'should let a admin edit meta' do
        expect(admin.can?(:edit, :games)).to be(true)
      end

      it "shouldn't let an old admin edit meta" do
        expect(old.can?(:edit, :games)).to be(false)
      end
    end

    describe 'Competition' do
      pending
    end
  end
end
