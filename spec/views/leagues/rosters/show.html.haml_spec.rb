require 'rails_helper'

describe 'leagues/rosters/show' do
  let(:roster) { build_stubbed(:league_roster) }
  let(:matches) { build_stubbed_list(:league_match, 3, home_team: roster) }

  it 'shows all data' do
    assign(:league, roster.league)
    assign(:roster, roster)
    assign(:matches, matches)

    render

    matches.each do |match|
      expect(rendered).to include(match.home_team.name)
      expect(rendered).to include(match.away_team.name)
    end
  end
end
