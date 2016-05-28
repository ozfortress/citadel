require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'meta/games/show' do
  let!(:game) { create(:game) }

  it 'shows data' do
    assign(:game, game)

    render

    expect(rendered).to include(game.name)
  end
end
