require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/index' do
  let!(:format) { create(:format) }
  let!(:league1) { create(:league, format: format, status: :running) }
  let!(:league2) { create(:league, format: format, status: :hidden) }

  before do
    view.lookup_context.prefixes = %w(application)
  end

  it 'displays all leagues' do
    assign(:leagues, League.paginate(page: 1))

    render

    expect(rendered).to include(format.game.name)
    expect(rendered).to include(league1.name)
    expect(rendered).to_not include(league2.name)
  end
end
