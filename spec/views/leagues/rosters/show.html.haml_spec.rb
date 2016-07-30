require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/rosters/show' do
  let(:roster) { create(:competition_roster) }

  before do
    5.times do
      create(:competition_match, home_team: roster)
    end
  end

  it 'shows all data' do
    assign(:competition, roster.competition)
    assign(:roster, roster)

    render

    #TODO: Check displayed data
  end
end

