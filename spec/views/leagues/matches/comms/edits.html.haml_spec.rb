require 'rails_helper'

describe 'leagues/matches/comms/edits' do
  let(:comm) { build_stubbed(:league_match_comm) }
  let(:edits) { build_stubbed_list(:league_match_comm_edit, 8, comm: comm) }

  it 'displays form' do
    assign(:comm, comm)
    assign(:match, comm.match)
    assign(:league, comm.match.league)
    assign(:edits, edits)

    render
  end
end
