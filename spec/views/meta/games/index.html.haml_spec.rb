require 'rails_helper'

describe 'meta/games/index' do
  let(:games) { build_stubbed_list(:game, 5) }

  it 'shows all games' do
    assign(:games, games)

    render

    games.each do |game|
      expect(rendered).to include(game.name)
    end
  end
end
