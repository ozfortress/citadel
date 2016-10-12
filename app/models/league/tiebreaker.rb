class League
  class Tiebreaker < ApplicationRecord
    belongs_to :league, inverse_of: :tiebreakers

    enum kind: [:round_wins, :round_score_difference, :round_wins_against_tied_rosters,
                :median_bucholz_score]

    def get_comparison(roster)
      send("get_#{kind}", roster)
    end

    private

    def get_round_wins(roster)
      roster.won_rounds_count
    end

    def get_round_score_difference(roster)
      roster.total_scores
    end

    def get_round_wins_against_tied_rosters(roster)
      tied_rosters = get_tied_rosters_for(roster)
      return 0 unless tied_rosters.exists?

      won_rounds = roster.won_rounds.joins(:match)
      won_rounds.where(league_matches: { home_team_id: tied_rosters })
                .union(won_rounds.where(league_matches: { away_team_id: tied_rosters }))
                .count
    end

    def get_median_bucholz_score(roster)
      roster.won_rounds_count * 1.0 + roster.drawn_rounds_count * 0.5
    end

    def get_tied_rosters_for(roster)
      roster.division.rosters.active.where(points: roster.points).where.not(id: roster.id)
    end
  end
end
