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
    roster.not_forfeited_home_team_sets.sum(:home_team_score) +
      roster.not_forfeited_away_team_sets.sum(:away_team_score)
  end

  def get_set_wins_against_tied_rosters(roster)
    tied_rosters = roster.division.approved_rosters.select { |r| r.points == roster.points }

    tied_rosters.map { |r| get_set_wins_against_roster(roster, r) }.sum
  end

  def get_set_wins_against_roster(roster, other)
    away_wins = roster.won_sets.joins(:match)
                      .where(competition_matches: { home_team_id: other.id })

    roster.won_sets.joins(:match).where(competition_matches: { away_team_id: other.id })
          .union(away_wins).count
  end

  def get_median_bucholz_score(roster)
    roster.won_sets_count * 1.0 + roster.drawn_sets_count * 0.5
  end
end
