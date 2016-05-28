require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'teams/show' do
  let!(:team) { create(:team) }
  let!(:transfers_in) { create_list(:transfer, 5, team: team, is_joining: true) }
  let!(:transfers_out) { create_list(:transfer, 5, team: team, is_joining: false) }
  let!(:rosters) { create_list(:competition_roster, 3, team: team) }

  it 'shows public team data' do
    assign(:team, team)

    render

    expect(rendered).to include(team.name)

    transfers_in.each do |transfer|
      expect(rendered).to include(transfer.user.name)
    end

    transfers_out.each do |transfer|
      expect(rendered).to include(transfer.user.name)
    end

    rosters.each do |roster|
      expect(rendered).to include(roster.name)
    end
  end

  it 'shows private team data'
end
