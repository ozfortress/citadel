require 'rails_helper'

describe 'meta/maps/edit' do
  let(:map) { create(:map) }

  it 'shows form' do
    pending 'routing issue'

    assign(:map, map)

    render
  end
end
