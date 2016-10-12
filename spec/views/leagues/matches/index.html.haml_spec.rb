require 'rails_helper'

describe 'leagues/matches/index' do
  let(:div) { build(:league_division) }
  let(:home_team) { build(:league_roster) }
  let(:away_team) { build(:league_roster) }

  before do
    @matches = []
    @matches << build_stubbed(:league_match, home_team: home_team,
                                             away_team: away_team, status: 'confirmed')
    @matches << build_stubbed(:league_match, home_team: home_team, away_team: nil)
    League::Match.forfeit_bies.each do |ff, _|
      @matches << build_stubbed(:league_match, home_team: home_team,
                                               away_team: away_team, forfeit_by: ff)
    end

    allow(div).to receive(:matches).and_return(@matches)
  end

  it 'displays matches' do
    allow(view).to receive(:user_can_edit_league?).and_return(true)
    assign(:league, div.league)
    assign(:divisions, [div])

    render

    @matches.each do |match|
      expect(rendered).to include(match.home_team.name)
    end
  end
end
