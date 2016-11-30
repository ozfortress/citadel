require 'rails_helper'

describe 'leagues/matches/comms/edit' do
  let(:comm) { build_stubbed(:league_match_comm) }

  it 'displays form' do
    assign(:comm, comm)
    assign(:match, comm.match)
    assign(:league, comm.match.league)

    render
  end
end
