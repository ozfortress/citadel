require 'rails_helper'

describe 'meta/games/index' do
  let!(:games) { create_list(:game, 5) }

  it 'shows all games' do
    render

    games.each do |game|
      expect(rendered).to include(game.name)
    end
  end
end
