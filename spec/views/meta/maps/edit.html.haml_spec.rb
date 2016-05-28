require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'meta/maps/edit' do
  let(:map) { create(:map) }

  it 'shows form' do
    pending 'routing issue'

    assign(:map, map)

    render
  end
end
