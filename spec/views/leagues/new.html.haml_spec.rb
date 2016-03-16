require 'spec_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/new.html.haml' do
  let(:comp) { build(:competition) }

  it 'displays form' do
    assign(:competition, comp)

    render
  end
end
