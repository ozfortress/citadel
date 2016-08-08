require 'rails_helper'

describe 'leagues/rosters/index' do
  let(:div) { create(:league_division) }
  let(:rosters) { create_list(:league_roster, 12, division: div) }

  it 'displays rosters' do
    assign(:league, div.league)

    render
  end
end
