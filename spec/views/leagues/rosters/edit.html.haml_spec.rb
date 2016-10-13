require 'rails_helper'

describe 'leagues/rosters/edit' do
  let(:roster) { build_stubbed(:league_roster) }

  before do
    assign(:league, roster.league)
    assign(:roster, roster)
  end

  context 'signuppable league' do
    before do
      roster.league.signuppable = true
    end

    it 'displays form for captains' do
      allow(view).to receive(:user_can_disband_roster?).and_return(true)

      render
    end

    it 'displays form for admins' do
      allow(view).to receive(:user_can_edit_league?).and_return(true)
      allow(view).to receive(:user_can_destroy_roster?).and_return(true)

      render
    end
  end

  context 'running league' do
    it 'displays form for captains' do
      allow(view).to receive(:user_can_disband_roster?).and_return(true)

      render
    end

    it 'displays form for admins' do
      allow(view).to receive(:user_can_edit_league?).and_return(true)
      allow(view).to receive(:user_can_destroy_roster?).and_return(true)

      render
    end
  end
end
