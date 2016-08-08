require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/show' do
  context 'private league' do
    let(:league) { create(:league) }

    it 'displays league details' do
      assign(:league, league)
      assign(:divisions, league.divisions.includes(:rosters))

      render

      expect(rendered).to include(league.name)
      description = ERB::Util.html_escape(league.description)
      expect(rendered).to include(description)
      expect(rendered).to include('Private')
    end
  end

  context 'public league with teams and signups open' do
    let!(:league) { create(:league, status: :running, signuppable: true) }
    let!(:div) { create(:league_division, league: league) }
    let!(:roster1) { create(:league_roster, division: div, approved: false) }
    let!(:roster2) { create(:league_roster, division: div, approved: true) }

    it 'displays league details' do
      assign(:league, league)
      assign(:divisions, league.divisions.includes(:rosters))

      render

      expect(rendered).to include(league.name)
      expect(rendered).to_not include(div.name)
      expect(rendered).to include(roster1.name)
      expect(rendered).to include(roster2.name)
    end
  end

  context 'public league with teams and signups closed' do
    let!(:league) { create(:league, status: :running, signuppable: false) }
    let!(:div) { create(:league_division, league: league) }
    let!(:roster1) { create(:league_roster, division: div, approved: false) }
    let!(:roster2) { create(:league_roster, division: div, approved: true) }
    let!(:roster3) { create(:league_roster, division: div, disbanded: true) }

    before do
      League::Tiebreaker.kinds.each do |_, kind|
        create(:league_tiebreaker, league: league, kind: kind)
      end
    end

    it 'displays league details' do
      assign(:league, league)
      assign(:divisions, league.divisions.includes(:rosters))

      render

      expect(rendered).to include(league.name)
      expect(rendered).to include(div.name)
      expect(rendered).to_not include(roster1.name)
      expect(rendered).to include(roster2.name)
      expect(rendered).to include(roster3.name)
    end
  end
end
