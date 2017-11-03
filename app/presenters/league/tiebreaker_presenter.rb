class League
  class TiebreakerPresenter < BasePresenter
    presents :tiebreaker

    NAMES = {
      'round_wins'                      => 'Wins',
      'round_score_difference'          => 'Total Score',
      'round_wins_against_tied_rosters' => 'Tied Wins',
      'median_bucholz_score'            => 'Buchholz',
    }.freeze

    TITLES = {
      'round_wins'                      => 'Total number of rounds won',
      'round_score_difference'          => 'Sum of scores of all rounds',
      'round_wins_against_tied_rosters' => 'Maps won against tied teams',
      'median_bucholz_score'            => 'Median Buchholz score',
    }.freeze

    def name
      NAMES[tiebreaker.kind]
    end

    def title
      TITLES[tiebreaker.kind]
    end

    def name_with_tooltip
      content_tag(:div, name, data: { toggle: :tooltip, placement: :bottom }, title: title)
    end
  end
end
