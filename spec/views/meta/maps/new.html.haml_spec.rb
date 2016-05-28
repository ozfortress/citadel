require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'meta/maps/new' do
  it 'shows form' do
    assign(:map, Map.new)

    render
  end
end
