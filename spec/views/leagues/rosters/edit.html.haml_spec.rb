require 'rails_helper'

describe 'leagues/rosters/edit' do
  let(:roster) { create(:league_roster) }
  let(:captain) { create(:user) }
  let(:admin) { create(:user) }

  before do
    captain.grant(:edit, roster.team)
    admin.grant(:edit, roster.team)
  end

  context 'signuppable league' do
    before do
      roster.league.update!(signuppable: true)
    end

    it 'displays form for captains' do
      sign_in captain
      assign(:roster, roster)
      assign(:league, roster.league)

      render
    end

    it 'displays form for admins' do
      sign_in admin
      assign(:roster, roster)
      assign(:league, roster.league)

      render
    end
  end

  context 'running league' do
    it 'displays form for captains' do
      sign_in captain
      assign(:roster, roster)
      assign(:league, roster.league)

      render
    end

    it 'displays form for admins' do
      sign_in admin
      assign(:roster, roster)
      assign(:league, roster.league)

      render
    end
  end
end
