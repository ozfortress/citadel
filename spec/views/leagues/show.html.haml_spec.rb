require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/show' do
  context 'private league' do
    let(:comp) { create(:competition) }

    it 'displays league details' do
      assign(:competition, comp)

      render

      expect(rendered).to include(comp.name)
      description = ERB::Util.html_escape(comp.description)
      expect(rendered).to include(description)
      expect(rendered).to include('Private')
    end
  end

  context 'public league with teams and signups open' do
    let!(:comp) { create(:competition, status: :hidden, signuppable: true) }
    let!(:div) { create(:division, competition: comp) }
    let!(:roster1) { create(:competition_roster, division: div, approved: false) }
    let!(:roster2) { create(:competition_roster, division: div, approved: true) }

    it 'displays league details' do
      assign(:competition, comp)

      render

      expect(rendered).to include(comp.name)
      expect(rendered).to_not include(div.name)
      expect(rendered).to include(roster1.name)
      expect(rendered).to include(roster2.name)
    end
  end

  context 'public league with teams and signups closed' do
    let!(:comp) { create(:competition, status: :hidden, signuppable: false) }
    let!(:div) { create(:division, competition: comp) }
    let!(:roster1) { create(:competition_roster, division: div, approved: false) }
    let!(:roster2) { create(:competition_roster, division: div, approved: true) }
    let!(:roster3) { create(:competition_roster, division: div, disbanded: true) }

    it 'displays league details' do
      assign(:competition, comp)

      render

      expect(rendered).to include(comp.name)
      expect(rendered).to include(div.name)
      expect(rendered).to_not include(roster1.name)
      expect(rendered).to include(roster2.name)
      expect(rendered).to include(roster3.name)
    end
  end
end
