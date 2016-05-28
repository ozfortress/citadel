require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'meta/formats/edit' do
  let(:format) { create(:format) }

  it 'shows form' do
    pending 'routing issue'

    assign(:format, format)

    render
  end
end
