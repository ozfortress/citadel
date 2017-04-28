require 'tournament-system'

class TournamentDriver < Tournament::Driver
  def initialize(division, match_options = {}, options = {})
    @division = division
    @match_options = match_options

    @teams_limit = (options[:teams_limit] || 0).to_i
    @teams_limit = nil if @teams_limit <= 0

    @starting_round = (options[:starting_round] || 0).to_i
    @starting_round = 0 if @starting_round <= 0

    @include_disbands = options[:include_disbands]

    @created_matches = []
  end

  attr_reader :created_matches

  def division_rosters
    @division.rosters.active.limit(@teams_limit)
  end

  def extra_rosters
    if @include_disbands
      [nil] * @division.rosters.where(disbanded: true).size
    else
      []
    end
  end

  def matches
    @matches ||= @division.matches.order(:id).where('round_number >= ?', @starting_round).to_a
  end

  def seeded_teams
    @seeded_teams ||= division_rosters.seeded.to_a + extra_rosters
  end

  def ranked_teams
    @ranked_teams ||= division_rosters.ordered(@division.league).to_a
  end

  def get_match_winner(match)
    match.winner
  end

  def get_match_teams(match)
    [match.home_team, match.away_team]
  end

  def get_team_score(team)
    team.points
  end

  def build_match(home_team, away_team)
    options = @match_options.merge(home_team: home_team, away_team: away_team)
    @created_matches << League::Match.new(options)
  end
end
