require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'teams/index' do
  let!(:teams) { create_list(:team, 4) }

  before do
    view.lookup_context.prefixes = %w(application)
  end

  it 'shows all teams' do
    assign(:teams, Team.paginate(page: 1))

    render

    teams.each do |team|
      expect(rendered).to include(team.name)
    end
  end
end
