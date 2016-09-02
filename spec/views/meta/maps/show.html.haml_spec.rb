require 'rails_helper'

describe 'meta/maps/show' do
  let!(:map) { create(:map) }

  it 'shows data' do
    assign(:map, map)

    render

    expect(rendered).to include(map.name)
  end
end
