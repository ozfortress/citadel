require 'rails_helper'

describe 'leagues/rosters/edit' do
  let(:roster) { create(:competition_roster) }
  let(:captain) { create(:user) }
  let(:admin) { create(:user) }

  before do
    captain.grant(:edit, roster.team)
    admin.grant(:edit, roster.team)
  end

  context 'signuppable league' do
    before do
      roster.competition.update!(signuppable: true)
    end

    it 'displays form for captains' do
      sign_in captain
      assign(:roster, roster)
      assign(:competition, roster.competition)

      render
    end

    it 'displays form for admins' do
      sign_in admin
      assign(:roster, roster)
      assign(:competition, roster.competition)

      render
    end
  end

  context 'running league' do
    it 'displays form for captains' do
      sign_in captain
      assign(:roster, roster)
      assign(:competition, roster.competition)

      render
    end

    it 'displays form for admins' do
      sign_in admin
      assign(:roster, roster)
      assign(:competition, roster.competition)

      render
    end
  end
end
