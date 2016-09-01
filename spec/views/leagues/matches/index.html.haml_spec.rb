require 'rails_helper'

describe 'leagues/matches/index' do
  let(:div) { create(:league_division) }
  let(:matches) { create_list(:league_match, 12, division: div) }

  it 'displays matches' do
    allow(view).to receive(:user_can_edit_league?).and_return(true)
    assign(:league, div.league)

    render
  end
end
