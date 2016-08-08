require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/matches/new' do
  let(:match) { build(:league_match) }

  it 'displays form' do
    assign(:league, match.league)
    assign(:match, match)

    render
  end
end
