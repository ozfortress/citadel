require 'rails_helper'

describe 'meta/maps/edit' do
  let(:map) { build_stubbed(:map) }

  it 'shows form' do
    assign(:map, map)

    render
  end
end
