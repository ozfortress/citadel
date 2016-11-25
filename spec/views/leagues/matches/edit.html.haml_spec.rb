require 'rails_helper'

describe 'leagues/matches/edit' do
  let(:match) { build_stubbed(:league_match) }

  it 'displays form' do
    assign(:league, match.league)
    assign(:match, match)

    render
  end
end
