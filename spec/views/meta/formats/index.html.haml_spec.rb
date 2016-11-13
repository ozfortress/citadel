require 'rails_helper'

describe 'meta/formats/index' do
  let(:formats) { build_stubbed_list(:format, 5) }

  it 'shows all formats' do
    assign(:formats, formats)

    render

    formats.each do |format|
      expect(rendered).to include(format.name)
    end
  end
end
