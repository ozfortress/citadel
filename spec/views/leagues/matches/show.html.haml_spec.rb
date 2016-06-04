require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/matches/show' do
  context 'home team has more players' do
    let(:div) { create(:division) }
    let(:home_team) { create(:competition_roster, division: div, player_count: 12) }
    let(:away_team) { create(:competition_roster, division: div, player_count: 6) }
    let(:match) { create(:competition_match, home_team: home_team, away_team: away_team) }

    it 'displays all players' do
      assign(:competition, div.competition)
      assign(:match, match)

      render

      home_team.player_users.each do |user|
        expect(rendered).to include(user.name)
      end
      away_team.player_users.each do |user|
        expect(rendered).to include(user.name)
      end
    end
  end

  context 'away team has more players' do
    let(:div) { create(:division) }
    let(:home_team) { create(:competition_roster, division: div, player_count: 6) }
    let(:away_team) { create(:competition_roster, division: div, player_count: 12) }
    let(:match) { create(:competition_match, home_team: home_team, away_team: away_team) }

    it 'displays all players' do
      assign(:competition, div.competition)
      assign(:match, match)

      render

      home_team.player_users.each do |user|
        expect(rendered).to include(user.name)
      end
      away_team.player_users.each do |user|
        expect(rendered).to include(user.name)
      end
    end
  end

  context 'standard match' do
    let(:match) { create(:competition_match) }
    let(:user) { create(:user) }
    let!(:comms) { create_list(:competition_comm, 12, match: match) }

    before do
      assign(:competition, match.competition)
      assign(:match, match)
      assign(:comm, CompetitionComm.new(match: match))
    end

    it 'displays for home team captains' do
      user.grant(:edit, match.home_team.team)
      sign_in user

      render
    end

    it 'displays for away team captains' do
      user.grant(:edit, match.away_team.team)
      sign_in user

      render
    end

    it 'displays for admins' do
      user.grant(:edit, match.competition)
      sign_in user

      render
    end

    it 'displays for unauthorized user' do
      sign_in user

      render
    end

    it 'displays for unauthenticated user' do
      render
    end

    after do
      comms.each do |comm|
        expect(rendered).to include(comm.content)
      end
    end
  end
end
