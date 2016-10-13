require 'rails_helper'

describe 'leagues/rosters/index' do
  let(:league) { build_stubbed(:league) }
  let(:divisions) { build_list(:league_division, 3, league: league) }

  before do
    divisions.each do |division|
      rosters = build_stubbed_list(:league_roster, 4, division: division)
      allow(division).to receive(:rosters).and_return(rosters)
    end
  end

  it 'displays rosters' do
    assign(:league, league)
    assign(:divisions, divisions)

    render
  end
end
