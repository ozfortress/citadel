require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'meta/formats/new' do
  it 'shows form' do
    assign(:format, Format.new)

    render
  end
end
