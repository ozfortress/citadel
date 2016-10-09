require 'rails_helper'

describe Team::Player do
  before { create(:team_player) }
  before { create(:team) }

  it { should belong_to(:team) }
  it { should_not allow_value(nil).for(:team) }

  it { should belong_to(:user) }
  it { should_not allow_value(nil).for(:user) }
  # it { should validate_uniqueness_of(:user).scoped_to(:team) }

  it 'creates transfers after creation' do
    team = create(:team)
    user = create(:user)

    team.players.create!(user: user)

    expect(team.transfers.size).to eq(1)
    transfer = team.transfers.first
    expect(transfer.user).to eq(user)
  end
end
