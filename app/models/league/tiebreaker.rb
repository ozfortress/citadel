class League
  class Tiebreaker < ApplicationRecord
    belongs_to :league, inverse_of: :tiebreakers

    enum kind: [:round_wins, :round_score_difference, :round_wins_against_tied_rosters,
                :median_bucholz_score]

    def get_comparison(roster)
      send("get_#{kind}", roster)
    end

    def get_round_wins(roster)
      roster.won_rounds_count
    end

    def get_round_score_difference(roster)
      roster.total_scores
    end

    def get_round_wins_against_tied_rosters(roster)
      roster.won_rounds_against_tied_rosters_count
    end

    def get_median_bucholz_score(roster)
      roster.won_rounds_count * 1.0 + roster.drawn_rounds_count * 0.5
    end
  end
end
