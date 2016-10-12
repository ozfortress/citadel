require 'rails_helper'

describe 'teams/index' do
  let!(:teams) { create_list(:team, 4) }

  it 'shows all teams' do
    assign(:teams, Team.paginate(page: 1))

    render

    teams.each do |team|
      expect(rendered).to include(team.name)
    end
  end
end
