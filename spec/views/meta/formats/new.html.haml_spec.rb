require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'meta/formats/new.html.haml' do
  it 'shows form' do
    assign(:format, Format.new)

    render
  end
end
