class League
  class Tiebreaker < ApplicationRecord
    belongs_to :league, inverse_of: :tiebreakers

    enum kind: [:round_wins, :round_score_difference, :round_wins_against_tied_rosters,
                :median_bucholz_score]

    def value_for(roster)
      send("#{kind}_value_for", roster)
    end

    def order
      send("#{kind}_order")
    end

    def round_wins_value_for(roster)
      roster.won_rounds_count
    end

    def round_wins_order
      'won_rounds_count DESC'
    end

    def round_score_difference_value_for(roster)
      roster.total_scores
    end

    def round_score_difference_order
      'total_scores DESC'
    end

    def round_wins_against_tied_rosters_value_for(roster)
      roster.won_rounds_against_tied_rosters_count
    end

    def round_wins_against_tied_rosters_order
      'won_rounds_against_tied_rosters_count DESC'
    end

    def median_bucholz_score_value_for(roster)
      roster.won_rounds_count * 1.0 + roster.drawn_rounds_count * 0.5
    end

    def median_bucholz_score_order
      '(won_rounds_count * 1.0 + drawn_rounds_count * 0.5) DESC'
    end
  end
end
