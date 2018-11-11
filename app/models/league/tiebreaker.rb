class League
  class Tiebreaker < ApplicationRecord
    belongs_to :league, inverse_of: :tiebreakers

    enum kind: [:round_wins, :round_score_sum, :round_wins_against_tied_rosters,
                :median_bucholz_score, :round_score_difference]

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

    def round_score_sum_value_for(roster)
      roster.total_scores
    end

    def round_score_sum_order
      'total_scores DESC'
    end

    def round_wins_against_tied_rosters_value_for(roster)
      roster.won_rounds_against_tied_rosters_count
    end

    def round_wins_against_tied_rosters_order
      'won_rounds_against_tied_rosters_count DESC'
    end

    def buchholz_helper_get_opponent_score(match, roster)
      (away_team.won_rounds_count if match.home_team_id == roster.id) ||
        (home_team.won_rounds_count if match.away_team_id == roster.id) || 0
    end

    def buchholz_helper_new_min_score(min_score, opponent_score)
      opponent_score unless min_score.negative? || opponent_score < min_score
    end

    def buchholz_helper_new_max_score(max_score, opponent_score)
      opponent_score unless max_score.negative? || opponent_score > max_score
    end

    def buchholz_helper_median(buchholz, min_score, max_score)
      buchholz - min_score + max_score unless min_score.negative? || max_score.negative?
    end

    def median_bucholz_score_value_for(roster)
      buchholz = 0
      min_score = max_score = -1
      roster.matches.each do |match|
        next if match.status.confirmed?
        opponent_score = buchholz_helper_get_opponent_score(match, roster)
        min_score = buchholz_helper_new_min_score(min_score, opponent_score)
        min_score = buchholz_helper_new_max_score(max_score, opponent_score)
        buchholz += opponent_score
      end
      buchholz_helper_median(buchholz, min_score, max_score)
    end

    def median_bucholz_score_order
      '(median_buchholz = 0
      min_score = max_score = -1
      roster.matches.each do |match|
        next if match.status.confirmed?
        opponent_score = buchholz_helper_get_opponent_score(match, roster)
        min_score = buchholz_helper_new_min_score(min_score, opponent_score)
        min_score = buchholz_helper_new_max_score(max_score, opponent_score)
        median_buchholz += opponent_score
      end
      buchholz_helper_median(buchholz, min_score, max_score)) DESC'
    end

    def round_score_difference_value_for(roster)
      roster.total_score_difference
    end

    def round_score_difference_order
      'total_score_difference DESC'
    end
  end
end
