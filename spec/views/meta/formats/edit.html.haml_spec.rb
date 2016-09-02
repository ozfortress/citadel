require 'rails_helper'

describe 'meta/formats/edit' do
  let(:format) { create(:format) }

  it 'shows form' do
    pending 'routing issue'

    assign(:format, format)

    render
  end
end
