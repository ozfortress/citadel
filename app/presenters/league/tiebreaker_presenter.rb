class League
  class TiebreakerPresenter < BasePresenter
    presents :tiebreaker

    NAMES = {
      'round_wins'                      => 'Wins',
      'round_score_sum'                 => 'Total Score',
      'round_wins_against_tied_rosters' => 'Direct Encounter',
      'normalized_round_score'          => 'Norm. Score',
      'round_score_difference'          => 'Score Difference',
      'buchholz'                        => 'Buchholz',
      'median_buchholz'                 => 'Median Buchholz',
    }.freeze

    TITLES = {
      'round_wins'                      => 'Total number of rounds won',
      'round_score_sum'                 => 'Sum of scores of all rounds',
      'round_wins_against_tied_rosters' => 'Rounds won against currently tied teams',
      'normalized_round_score'          => 'Normalized score based on round wins/draws',
      'round_score_difference'          => 'Total score difference of all rounds',
      'buchholz'                        => 'Sum of opponent scores times your score',
      'median_buchholz'                 => 'Sum of opponent scores times your score, ignoring the highest and lowest',
    }.freeze

    def name
      NAMES[tiebreaker.kind]
    end

    def title
      TITLES[tiebreaker.kind]
    end

    def name_with_tooltip
      content_tag(:u, name, data: { toggle: :tooltip, placement: :bottom }, title: title)
    end

    def value_for(roster)
      number_with_precision(
        tiebreaker.value_for(roster),
        strip_insignificant_zeros: true
      )
    end
  end
end
