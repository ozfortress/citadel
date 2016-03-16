require 'spec_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/edit.html.haml' do
  let(:comp) { create(:competition) }

  it 'displays form' do
    assign(:competition, comp)

    render
  end
end
