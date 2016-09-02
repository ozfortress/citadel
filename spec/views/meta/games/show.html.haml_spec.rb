require 'rails_helper'

describe 'meta/games/show' do
  let!(:game) { create(:game) }

  it 'shows data' do
    assign(:game, game)

    render

    expect(rendered).to include(game.name)
  end
end
