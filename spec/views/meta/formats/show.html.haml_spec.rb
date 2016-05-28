require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'meta/formats/show' do
  let!(:format) { create(:format) }

  it 'shows data' do
    assign(:format, format)

    render

    expect(rendered).to include(format.name)
  end
end
