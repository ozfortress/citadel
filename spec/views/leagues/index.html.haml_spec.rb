require 'rails_helper'

describe 'leagues/index' do
  let(:format) { create(:format) }
  let(:league1) { create(:league, format: format, status: :running) }
  let(:league2) { create(:league, format: format, status: :hidden) }
  let(:games) { [format.game] }

  it 'displays all leagues' do
    assign(:games, games)
    assign(:leagues, [league1, league2].group_by { |league| league.format.game })

    render

    expect(rendered).to include(format.game.name)
    expect(rendered).to include(league1.name)
    expect(rendered).to include(league2.name)
  end
end
