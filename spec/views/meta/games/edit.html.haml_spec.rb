require 'rails_helper'

describe 'meta/games/edit' do
  let(:game) { create(:game) }

  it 'shows form' do
    pending 'routing issue'

    assign(:game, game)

    render
  end
end
