require 'rails_helper'
require 'support/factory_girl'

describe 'meta/formats/new.html.haml' do
  let!(:format) { create(:format) }

  it 'shows form' do
    assign(:format, format)

    render
  end
end
