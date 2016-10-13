require 'rails_helper'

describe 'leagues/matches/show' do
  let(:league) { build_stubbed(:league) }
  let(:division) { build_stubbed(:league_division, league: league) }
  let(:home_team) { build_stubbed(:league_roster, player_count: 3, division: division) }
  let(:away_team) { build_stubbed(:league_roster, player_count: 3, division: division) }
  let(:match) { build_stubbed(:league_match, home_team: home_team, away_team: away_team) }
  let(:comms) { build_stubbed_list(:league_match_comm, 6) }

  before do
    assign(:league, league)
    assign(:match, match)
    assign(:comm, League::Match::Comm.new(match: match))
    assign(:comms, comms)
  end

  context 'home team has more players' do
    before do
      3.times do
        home_team.players << build_stubbed(:league_roster_player, roster: home_team)
      end
    end

    it 'displays all players' do
      render

      home_team.users.each do |user|
        expect(rendered).to include(user.name)
      end
      away_team.users.each do |user|
        expect(rendered).to include(user.name)
      end
    end
  end

  context 'away team has more players' do
    before do
      3.times do
        away_team.players << build_stubbed(:league_roster_player, roster: away_team)
      end
    end

    it 'displays all players' do
      render

      home_team.users.each do |user|
        expect(rendered).to include(user.name)
      end
      away_team.users.each do |user|
        expect(rendered).to include(user.name)
      end
    end
  end

  context 'BYE match' do
    before do
      match.away_team = nil
    end

    it 'displays' do
      render
    end
  end

  context 'standard match' do
    it 'displays for captains' do
      allow(view).to receive(:user_can_either_teams?).and_return(true)

      render
    end

    it 'displays for admins' do
      allow(view).to receive(:user_can_either_teams?).and_return(true)
      allow(view).to receive(:user_can_edit_league?).and_return(true)

      render
    end

    it 'displays for any user' do
      render
    end

    after do
      comms.each do |comm|
        expect(rendered).to include(comm.content)
      end
    end

    context 'with schedule' do
      before do
        days = Array.new(5, true) + Array.new(2, false)
        scheduler = build_stubbed(:league_schedulers_weekly, days: days, minimum_selected: 3)
        allow(league).to receive(:weekly_scheduler).and_return(scheduler)
        league.schedule = 'weeklies'

        schedule = { 'type' => 'weekly', 'availability' => {
          'Sunday' => 'true', 'Monday' => 'true', 'Tuesday' => 'true' } }
        home_team.schedule_data = schedule

        schedule['availability'] = {
          'Tuesday' => 'true', 'Wednesday' => 'true', 'Thursday' => 'true' }
        away_team.schedule_data = schedule
      end

      it 'displays schedule recomendation' do
        render

        expect(rendered).to include('Tuesday')
      end
    end
  end
end
