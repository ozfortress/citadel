require 'rails_helper'

describe 'leagues/rosters/new' do
  let(:team) { create(:team) }
  let(:team2) { create(:team) }
  let(:league) { create(:league) }
  let(:div) { create(:league_division, league: league) }
  let(:captain) { create(:user) }

  before do
    captain.grant(:edit, team)
    captain.grant(:edit, team2)
  end

  it 'displays form' do
    sign_in captain
    assign(:league, league)
    assign(:roster, league.rosters.new)

    render
  end

  it 'displays form for selected team' do
    sign_in captain
    assign(:league, league)
    assign(:roster, build(:league_roster, team: team, division: div))
    assign(:team, team)

    render
  end
end
