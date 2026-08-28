class League
  class Tiebreaker < ApplicationRecord
    belongs_to :league, inverse_of: :tiebreakers

    enum :kind, { round_wins: 0, round_score_sum: 1, round_wins_against_tied_rosters: 2,
                  normalized_round_score: 3, round_score_difference: 4, buchholz: 5, median_buchholz: 6 }

    def value_for(roster)
      send("#{kind}_value_for", roster)
    end

    def round_wins_value_for(roster)
      roster.won_rounds_count
    end

    def round_score_sum_value_for(roster)
      roster.total_scores
    end

    def round_wins_against_tied_rosters_value_for(roster)
      roster.won_rounds_against_tied_rosters_count
    end

    def normalized_round_score_value_for(roster)
      roster.normalized_round_score
    end

    def round_score_difference_value_for(roster)
      roster.total_score_difference
    end

    def buchholz_value_for(roster)
      roster.buchholz_score
    end

    def median_buchholz_value_for(roster)
      roster.median_buchholz_score
    end
  end
end
