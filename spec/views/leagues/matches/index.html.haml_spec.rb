require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/matches/index' do
  let(:div) { create(:league_division) }
  let(:matches) { create_list(:league_match, 12, division: div) }

  it 'displays matches' do
    assign(:league, div.league)

    render
  end
end
