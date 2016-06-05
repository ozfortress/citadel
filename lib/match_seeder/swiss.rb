module MatchSeeder
  module Swiss
    include MatchSeeder::Common

    extend self

    def seed_round_for(target, options = {})
      target.transaction do
        rosters = get_roster_pool(target)
        roster_points = map_points(rosters)
        roster_points.sort! { |x, y| y[1] <=> x[1] }
        rosters = roster_points.map { |x| x[0] }

        # puts roster_points.map { |x| [x[0].name, x[1]] }.join(", ")
        create_matches_for(rosters, options)
      end
    end

    private

    def map_points(rosters)
      rosters.map do |roster|
        if roster
          [roster, roster.points]
        else
          [roster, 0]
        end
      end
    end

    def not_played_before?(roster, other_roster)
      roster.rosters_not_played.include? other_roster
    end

    def next_closest_roster(home_roster, rosters)
      # Adjacent pairings, ignoring past pairings
      rosters.each do |roster|
        return roster if not_played_before?(home_roster, roster)
      end

      # In rare circumstances, we can't pair uniquely. So just pick at random
      # This can only happen at the bottom of the ladder
      rosters.sample
    end

    def create_matches_for(rosters, options)
      matches = []

      while rosters.size > 1
        home_team = rosters.shift
        away_team = next_closest_roster(home_team, rosters)
        rosters.delete away_team

        matches << create_match_for(home_team, away_team, options)
      end

      matches
    end
  end
end
