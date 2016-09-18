require 'rails_helper'

describe 'leagues/matches/index' do
  let(:div) { create(:league_division) }

  before do
    create_list(:league_match, 3, division: div)
    create_list(:league_match, 3, division: div, status: 'confirmed')
    League::Match.forfeit_bies.each do |ff, _|
      create(:league_match, division: div, status: 'confirmed', forfeit_by: ff)
    end
  end

  it 'displays matches' do
    allow(view).to receive(:user_can_edit_league?).and_return(true)
    assign(:league, div.league)

    render
  end
end
