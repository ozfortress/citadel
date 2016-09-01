require 'rails_helper'

describe 'leagues/matches/edit' do
  let(:match) { create(:league_match) }

  it 'displays form' do
    assign(:league, match.league)
    assign(:match, match)

    render
  end
end
