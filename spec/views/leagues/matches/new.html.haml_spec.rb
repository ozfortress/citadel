require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/matches/new' do
  let(:match) { build(:competition_match) }

  it 'displays form' do
    assign(:competition, match.competition)
    assign(:match, match)

    render
  end
end
