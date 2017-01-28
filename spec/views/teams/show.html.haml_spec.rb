require 'rails_helper'

describe 'teams/show' do
  let(:team) { build_stubbed(:team) }
  let(:invite) { build_stubbed(:team_invite) }
  let(:players) { build_stubbed_list(:team_player, 6) }
  let(:transfers_in) { build_stubbed_list(:team_transfer, 5, team: team, is_joining: true) }
  let(:transfers_out) { build_stubbed_list(:team_transfer, 5, team: team, is_joining: false) }
  let(:active_rosters) { build_stubbed_list(:league_roster, 3, team: team) }
  let(:past_rosters) { build_stubbed_list(:league_roster, 3, team: team) }
  let(:matches) { build_stubbed_list(:league_match, 4) }

  before do
    assign(:team, team)
    assign(:invite, invite)
    assign(:players, players)
    assign(:transfers, transfers_in + transfers_out)
    assign(:active_rosters, active_rosters)
    assign(:active_roster_matches, active_rosters.map { matches })
    assign(:past_rosters, past_rosters)
    assign(:past_roster_matches, past_rosters.map { matches })
    assign(:upcoming_matches, matches)
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

    (active_rosters + past_rosters).each do |roster|
      expect(rendered).to include(roster.name)

      roster.users.each do |user|
        expect(rendered).to include(user.name)
      end
    end

    matches.each do |match|
      expect(rendered).to include(match.home_team.name)
      expect(rendered).to include(match.away_team.name)
    end
  end
end
