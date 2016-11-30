require 'rails_helper'

describe Leagues::Matches::Comms::CreationService do
  let(:user) { create(:user) }
  let(:match) { create(:league_match) }
  let(:home_captain) { create(:user) }
  let(:away_captain) { create(:user) }

  before do
    home_captain.grant(:edit, match.home_team.team)
    away_captain.grant(:edit, match.away_team.team)
  end

  it 'user successfully posts a comm' do
    comm = subject.call(user, match, content: 'A')

    expect(comm).to be_valid
    expect(comm.content).to eq('A')
    expect(comm.user).to be(user)
    expect(user.notifications).to be_empty
    expect(home_captain.notifications).to_not be_empty
    expect(away_captain.notifications).to_not be_empty
  end

  it 'captain successfully submits a ban' do
    comm = subject.call(home_captain, match, content: 'A')

    expect(comm).to be_valid
    expect(comm.content).to eq('A')
    expect(comm.user).to be(home_captain)
    expect(user.notifications).to be_empty
    expect(home_captain.notifications).to be_empty
    expect(away_captain.notifications).to_not be_empty
  end

  it 'fails with invalid data' do
    comm = subject.call(user, match, content: nil)

    expect(comm).to be_invalid
    expect(user.notifications).to be_empty
    expect(home_captain.notifications).to be_empty
    expect(away_captain.notifications).to be_empty
  end
end
