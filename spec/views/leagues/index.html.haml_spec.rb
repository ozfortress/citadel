require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/index' do
  let!(:format) { create(:format) }
  let!(:comp1) { create(:competition, format: format, status: :running) }
  let!(:comp2) { create(:competition, format: format, status: :hidden) }

  it 'displays all leagues' do
    view.lookup_context.prefixes = %w(application)
    assign(:competitions, Competition.paginate(page: 1))

    render

    expect(rendered).to include(format.game.name)
    expect(rendered).to include(comp1.name)
    expect(rendered).to_not include(comp2.name)
  end
end
