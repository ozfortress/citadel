require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'teams/index' do
  let!(:teams) { create_list(:team, 4) }

  it 'shows all teams' do
    view.lookup_context.prefixes = %w(application)
    assign(:teams, Team.paginate(page: 1))

    render

    teams.each do |team|
      expect(rendered).to include(team.name)
    end
  end
end
