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

  shared_examples 'displays matches' do
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
  end

  context 'standard match' do
    include_examples 'displays matches'

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

    context 'with pending pick bans' do
      let(:pick_bans) { build_stubbed_list(:league_match_pick_ban, 3, match: match) }
      let(:map_pool) { build_stubbed_list(:map, 3) }

      before do
        allow(match).to receive(:pick_bans).and_return(pick_bans)
        allow(match).to receive(:picking_completed?).and_return(false)
        allow(match).to receive(:map_pool).and_return(map_pool)
      end

      include_examples 'displays matches'
    end

    context 'with completed pick bans' do
      let(:map) { build_stubbed(:map) }
      let(:user) { build_stubbed(:user) }
      let(:pick_bans) do
        build_stubbed_list(:league_match_pick_ban, 3, match: match, map: map, picked_by: user)
      end
      let(:map_pool) { build_stubbed_list(:map, 3) }

      before do
        allow(match).to receive(:pick_bans).and_return(pick_bans)
        allow(match).to receive(:picking_completed?).and_return(true)
        allow(match).to receive(:map_pool).and_return(map_pool)
      end

      include_examples 'displays matches'
    end
  end
end
