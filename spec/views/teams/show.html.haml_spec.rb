require 'rails_helper'

describe 'teams/show' do
  let(:team) { build_stubbed(:team) }
  let(:invite) { build_stubbed(:team_invite) }
  let(:players) { build_stubbed_list(:team_player, 6) }
  let(:transfers_in) { build_stubbed_list(:team_transfer, 5, team: team, is_joining: true) }
  let(:transfers_out) { build_stubbed_list(:team_transfer, 5, team: team, is_joining: false) }
  let(:active_league) { build_stubbed(:league) }
  let(:signup_league) { build_stubbed(:league, signuppable: true) }
  let(:completed_league) { build_stubbed(:league, status: :completed) }

  before do
    @active_rosters = [active_league, signup_league].map do |league|
      division = build_stubbed(:league_division, league: league)
      build_stubbed(:league_roster, division: division)
    end
    @active_rosters << build_stubbed(:league_roster, disbanded: true)

    past_div = build_stubbed(:league_division, league: completed_league)
    @past_rosters = []
    @past_rosters << build_stubbed(:league_roster, division: past_div)
    @past_rosters << build_stubbed(:league_roster, division: past_div, disbanded: true)

    roster = @active_rosters.first
    @matches = []
    @matches << build_stubbed(:league_match, home_team: roster, status: 'confirmed')
    @matches << build_stubbed(:league_match, home_team: roster, status: 'pending',
                                             round_name: 'Finals')
    @matches << build_stubbed(:bye_league_match, home_team: roster, status: 'confirmed')
    League::Match.forfeit_bies.each do |ff, _|
      @matches << build_stubbed(:league_match, home_team: roster, forfeit_by: ff,
                                               status: 'confirmed')
    end

    match = @matches.first
    rounds = []
    rounds << build_stubbed(:league_match_round, match: match, home_team_score: 2,
                                                 away_team_score: 1)
    rounds << build_stubbed(:league_match_round, match: match, home_team_score: 1,
                                                 away_team_score: 2)
    rounds << build_stubbed(:league_match_round, match: match, home_team_score: 3,
                                                 away_team_score: 3)
    @matches.each do |match_|
      allow(match_).to receive(:rounds).and_return(rounds)
    end

    assign(:team, team)
    assign(:invite, invite)
    assign(:players, players)
    assign(:transfers, transfers_in + transfers_out)
    assign(:active_rosters, @active_rosters)
    assign(:active_roster_matches, @active_rosters.map { @matches })
    assign(:past_rosters, @past_rosters)
    assign(:past_roster_matches, @past_rosters.map { @matches })
    assign(:upcoming_matches, @matches)
  end

  it 'shows public team data' do
    render

    expect(rendered).to include(team.name)

    players.each do |player|
      expect(rendered).to include(player.user.name)
    end

    transfers_in.each do |transfer|
      expect(rendered).to include(transfer.user.name)
    end

    transfers_out.each do |transfer|
      expect(rendered).to include(transfer.user.name)
    end

    (@active_rosters + @past_rosters).each do |roster|
      expect(rendered).to include(roster.name)

      roster.users.each do |user|
        expect(rendered).to include(user.name)
      end
    end

    @matches.each do |match|
      expect(rendered).to include(match.home_team.name)
      expect(rendered).to include(match.away_team.name) if match.away_team
    end
  end
end
