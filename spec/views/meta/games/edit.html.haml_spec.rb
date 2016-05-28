require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'meta/games/edit' do
  let(:game) { create(:game) }

  it 'shows form' do
    pending 'routing issue'

    assign(:game, game)

    render
  end
end
