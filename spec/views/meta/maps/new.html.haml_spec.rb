require 'rails_helper'

describe 'meta/maps/new' do
  it 'shows form' do
    assign(:map, Map.new)

    render
  end
end
