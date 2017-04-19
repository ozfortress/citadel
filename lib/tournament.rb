require 'tournament-system'

class TournamentDriver < Tournament::Driver
  def initialize(division, match_options = {}, options = {})
    @division = division
    @match_options = match_options

    @teams_limit = options[:teams_limit] || 0
    @teams_limit = nil if @teams_limit.to_i <= 0

    @starting_round = options[:starting_round] || 0
    @starting_round = 0 if @starting_round.to_i <= 0

    @created_matches = []
  end

  attr_reader :created_matches

  def division_rosters
    @division.rosters.active.limit(@teams_limit)
  end

  def division_matches
    @matches ||= @division.matches.where('round_number >= ?', @starting_round).to_a
  end

  def division_matches_map
    @matches_map ||= division_matches.group_by(&:round_number)
  end

  def matches
    division_matches
  end

  def matches_for_round(round)
    division_matches_map[round - @starting_round]
  end

  def seeded_teams
    @seeded_teams ||= division_rosters.seeded.to_a
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
