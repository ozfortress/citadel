require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe User do
  before { create(:user) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }

  it { should validate_presence_of(:steam_id) }
  it { should validate_uniqueness_of(:steam_id) }
  it { should validate_numericality_of(:steam_id).is_greater_than(0) }

  describe 'Permissions' do
    describe 'Teams' do
      let(:team)   { create(:team, name: 'A') }
      let(:team2)  { create(:team, name: 'B') }
      let(:user)   { create(:user, name: 'A', steam_id: 1) }
      let(:leader) { create(:user, name: 'B', steam_id: 2) }
      let(:admin)  { create(:user, name: 'C', steam_id: 3) }

      before do
        leader.grant(:edit, team)
        admin.grant(:edit, :teams)
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
    end
  end
end
