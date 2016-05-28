require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'meta/maps/show' do
  let!(:map) { create(:map) }

  it 'shows data' do
    assign(:map, map)

    render

    expect(rendered).to include(map.name)
  end
end
