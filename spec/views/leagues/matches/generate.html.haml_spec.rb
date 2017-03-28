require 'rails_helper'

describe 'leagues/matches/generate' do
  let(:match) { build(:league_match) }

  it 'displays form' do
    assign(:league, match.league)
    assign(:match, match)
    assign(:division, match.division)
    assign(:tournament_system, :swiss)
    assign(:swiss_tournament, pairer: :dutch, pair_options: { min_pair_size: 6 })
    assign(:round_robin_tournament, {})
    assign(:single_elimination_tournament, teams_limit: 4, round: 2)
    assign(:page_playoffs_tournament, starting_round: 2)

    render
  end
end
