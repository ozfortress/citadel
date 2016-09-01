require 'rails_helper'

describe 'leagues/matches/show' do
  context 'home team has more players' do
    let(:div) { create(:league_division) }
    let(:home_team) { create(:league_roster, division: div, player_count: 12) }
    let(:away_team) { create(:league_roster, division: div, player_count: 6) }
    let(:match) { create(:league_match, home_team: home_team, away_team: away_team) }

    it 'displays all players' do
      assign(:league, div.league)
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
    let(:div) { create(:league_division) }
    let(:home_team) { create(:league_roster, division: div, player_count: 6) }
    let(:away_team) { create(:league_roster, division: div, player_count: 12) }
    let(:match) { create(:league_match, home_team: home_team, away_team: away_team) }

    it 'displays all players' do
      assign(:league, div.league)
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

  context 'BYE match' do
    let(:match) { create(:bye_league_match) }

    it 'displays' do
      assign(:league, match.league)
      assign(:match, match)

      render
    end
  end

  context 'standard match' do
    let(:match) { create(:league_match) }
    let(:user) { create(:user) }
    let!(:comms) { create_list(:league_match_comm, 12, match: match) }

    before do
      assign(:league, match.league)
      assign(:match, match)
      assign(:comm, League::Match::Comm.new(match: match))
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
      user.grant(:edit, match.league)
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
