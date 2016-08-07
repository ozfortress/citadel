class CompetitionTiebreaker < ActiveRecord::Base
  belongs_to :competition

  enum kind: [:set_wins, :set_score_difference, :set_wins_against_tied_rosters,
              :median_bucholz_score]

  def get_comparison(roster)
    send("get_#{kind}", roster)
  end

  private

  def get_set_wins(roster)
    roster.won_sets_count
  end

  def get_set_score_difference(roster)
    roster.total_scores
  end

  def get_set_wins_against_tied_rosters(roster)
    tied_rosters = roster.division.approved_rosters.where(points: roster.points)

    return 0 unless tied_rosters.exists?

    won_sets = roster.won_sets.joins(:match)
    won_sets.where(competition_matches: { home_team_id: tied_rosters })
            .union(won_sets.where(competition_matches: { away_team_id: tied_rosters }))
            .count
  end

  def get_median_bucholz_score(roster)
    roster.won_sets_count * 1.0 + roster.drawn_sets_count * 0.5
  end
end
