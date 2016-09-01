require 'rails_helper'

describe 'meta/formats/new' do
  it 'shows form' do
    assign(:format, Format.new)

    render
  end
end
