require 'rails_helper'

describe 'meta/formats/edit' do
  let(:format) { build_stubbed(:format) }

  it 'shows form' do
    assign(:format, format)

    render
  end
end
