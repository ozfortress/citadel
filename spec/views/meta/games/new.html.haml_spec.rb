require 'rails_helper'

describe 'meta/games/new' do
  it 'shows form' do
    assign(:game, Game.new)

    render
  end
end
