class League
  class TiebreakerPresenter < ActionPresenter::Base
    presents :tiebreaker

    NAMES = {
      'round_wins'                      => 'Wins',
      'round_score_difference'          => 'Total Score',
      'round_wins_against_tied_rosters' => 'Tied Wins',
      'median_bucholz_score'            => 'Buchholz'
    }.freeze

    def name
      NAMES[tiebreaker.kind]
    end
  end
end
