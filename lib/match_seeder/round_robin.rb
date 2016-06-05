require 'set'

module MatchSeeder
  module RoundRobin
    extend self

    def seed_round_for(target, options = {})
      target.transaction do
        rosters = get_roster_pool(target)

        round_no = target.matches.size / (rosters.size / 2)

        rosters = advance_rounds(rosters, round_no)
        create_matches_for(rosters, options)
      end
    end

    private

    def get_roster_pool(target)
      rosters = target.approved_rosters
      rosters << nil if rosters.size.odd?
      rosters
    end

    def advance_rounds(rosters, round_no)
      wrap_size = rosters.size - 1

      rosters.each_with_index.map do |roster, index|
        if index == 0
          roster
        else
          rosters[(index - 1 + round_no) % wrap_size + 1]
        end
      end
    end

    def create_matches_for(rosters, options)
      rosters_size = rosters.size
      round_size = (rosters_size / 2)

      top_row = rosters[0...round_size]
      bottom_row = rosters[round_size...rosters_size].reverse

      top_row.zip(bottom_row).map do |home_team, away_team|
        create_match_for(home_team, away_team, options)
      end
    end

    def create_match_for(home_team, away_team, options)
      # Swap home and away team to spread out home/away matches
      if home_team && away_team &&
         (home_team.home_team_matches.size > home_team.away_team_matches.size ||
          away_team.away_team_matches.size > away_team.home_team_matches.size) ||
         !home_team
        home_team, away_team = away_team, home_team
      end

      match_options = options.merge(home_team: home_team, away_team: away_team)

      CompetitionMatch.create!(match_options)
    end
  end
end
