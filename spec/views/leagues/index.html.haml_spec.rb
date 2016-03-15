require 'spec_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/index.html.haml' do
  let!(:format) { create(:format) }
  let!(:comp1) { create(:competition, format: format, private: false) }
  let!(:comp2) { create(:competition, format: format, private: true) }

  it 'displays all leagues' do
    render

    expect(rendered).to include(format.game.name)
    expect(rendered).to include(comp1.name)
    expect(rendered).to_not include(comp2.name)
  end
end
