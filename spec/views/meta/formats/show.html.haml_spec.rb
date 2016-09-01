require 'rails_helper'

describe 'meta/formats/show' do
  let!(:format) { create(:format) }

  it 'shows data' do
    assign(:format, format)

    render

    expect(rendered).to include(format.name)
  end
end
