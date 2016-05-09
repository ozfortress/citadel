require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/rosters/new.html.haml' do
  let(:team) { create(:team) }
  let(:team2) { create(:team) }
  let(:comp) { create(:competition) }
  let(:div) { create(:division, competition: comp) }
  let(:captain) { create(:user) }

  before do
    captain.grant(:edit, team)
    captain.grant(:edit, team2)
  end

  it 'displays form' do
    sign_in captain
    assign(:competition, comp)
    assign(:roster, CompetitionRoster.new)

    render
  end

  it 'displays form for selected team' do
    sign_in captain
    assign(:competition, comp)
    assign(:roster, build(:competition_roster, team: team, division: div))

    render
  end
end
