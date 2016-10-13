require 'rails_helper'

describe 'leagues/rosters/review' do
  let(:roster) { build_stubbed(:league_roster) }

  it 'displays correctly' do
    assign(:league, roster.league)
    assign(:roster, roster)

    render
  end
end
