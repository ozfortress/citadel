require 'rails_helper'

describe 'meta/games/edit' do
  let(:game) { build_stubbed(:game) }

  it 'shows form' do
    assign(:game, game)

    render
  end
end
