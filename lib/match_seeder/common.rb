module MatchSeeder
  module Common
    extend self

    def get_roster_pool(target)
      rosters = target.approved_rosters
      rosters << nil if rosters.size.odd?
      rosters.to_a
    end

    def create_match_for(home_team, away_team, options)
      # Swap home and away team to spread out home/away matches
      if home_team && away_team &&
         (home_team.home_team_matches.size > home_team.away_team_matches.size ||
          away_team.away_team_matches.size > away_team.home_team_matches.size) ||
         !home_team
        home_team, away_team = away_team, home_team
      end

      match_options = get_opts(home_team, away_team, options)
      CompetitionMatch.create!(match_options)
    end

    private

    def get_opts(home_team, away_team, options)
      match_options = options.merge(home_team: home_team, away_team: away_team)

      match_options[:sets] = match_options[:sets].map(&:dup) if match_options.key? :sets

      match_options
    end
  end
end
