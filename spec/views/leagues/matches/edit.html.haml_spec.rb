require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/matches/edit' do
  let(:match) { create(:league_match) }

  it 'displays form' do
    assign(:league, match.league)
    assign(:match, match)

    render
  end
end
