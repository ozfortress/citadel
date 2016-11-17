require 'rails_helper'

describe 'meta/maps/index' do
  let(:maps) { build_stubbed_list(:map, 5) }

  it 'shows all maps' do
    assign(:maps, maps)

    render

    maps.each do |map|
      expect(rendered).to include(map.name)
    end
  end
end
