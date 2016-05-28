require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'meta/games/new' do
  it 'shows form' do
    assign(:game, Game.new)

    render
  end
end
