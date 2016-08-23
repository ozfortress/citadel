require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/rosters/show' do
  let(:roster) { create(:league_roster) }
  let(:matches) { create_list(:league_match, 5, home_team: roster) }

  it 'shows all data' do
    assign(:league, roster.league)
    assign(:roster, roster)
    assign(:matches, matches)

    render

    # TODO: Check displayed data
  end
end
