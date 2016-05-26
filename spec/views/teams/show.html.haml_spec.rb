require 'rails_helper'

describe 'teams/show.html.haml' do
  let(:team) { create(:team) }

  # TODO: data setup

  it 'shows public team data' do
    assign(:team, team)

    render

    expect(rendered).to include(team.name)
    # TODO: Add more checks for team data
  end

  it 'shows private team data'
end
