module MatchSeeder
  module Swiss
    include MatchSeeder::Common

    extend self

    def get_roster_pool(target)
      rosters = Common.get_roster_pool(target)

      # We can just ignore disbanded rosters
      rosters.reject(&:disbanded?)
    end

    def seed_round_for(target, options = {})
      transaction do
        rosters = get_roster_pool(target)
        roster_points = map_points(rosters)
        roster_points.sort! { |x, y| y[1] <=> x[1] }
        rosters = roster_points.map { |x| x[0] }

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

    # :reek:DuplicateMethodCall { allow_calls: ['rosters.size'] }
    def create_matches_for(rosters, options)
      matches = []

      # Pick BYE first, if needed
      matches << create_bye_match(rosters, options) unless rosters.size.even?

      while rosters.size > 1
        home_team = rosters.shift
        away_team = next_closest_roster(home_team, rosters)
        rosters.delete away_team

        matches << create_match_for(home_team, away_team, options)
      end

      matches
    end

    def create_bye_match(rosters, options)
      roster_byes = rosters.map { |roster| [roster, roster.home_team_matches.bye.size] }

      # Select roster to BYE from back to front
      max_bies = roster_byes.map(&:second).max

      team = roster_byes.select { |r_bye| r_bye.second < max_bies }.map(&:first).last
      team ||= rosters.last
      rosters.delete(team)

      create_match_for(team, nil, options)
    end
  end
end
