module MatchSeeder
  module RoundRobin
    include MatchSeeder::Common

    extend self

    def get_roster_pool(target)
      rosters = Common.get_roster_pool(target).to_a

      # Replace disbanded rosters with nil to keep seeding consistent
      rosters.map! { |roster| roster.disbanded? ? nil : roster }

      rosters << nil if rosters.size.odd?

      rosters
    end

    def seed_round_for(target, options = {})
      transaction do
        rosters = get_roster_pool(target)

        round_no = target.matches.size / (rosters.size / 2)

        rosters = advance_rounds(rosters, round_no)
        create_matches_for(rosters, options)
      end
    end

    private

    def advance_rounds(rosters, round_no)
      wrap_size = rosters.size - 1

      rosters.each_with_index.map do |roster, index|
        if index.zero?
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
        next unless home_team || away_team

        # Make sure that BYE matches have the home_team as the bye'd team
        create_match_for(home_team || away_team, home_team && away_team, options)
      end
    end
  end
end
