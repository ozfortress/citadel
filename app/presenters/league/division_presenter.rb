class League
  class DivisionPresenter < BasePresenter
    presents :division

    def bracket_data(rosters, matches)
      rosters = rosters.index_by(&:id)
      matches = matches.group_by(&:round_number)
      rounds  = matches.keys.sort

      # rubocop:disable Rails/OutputSafety
      {
        rounds:  rounds.map { |round| html_escape present(matches[round].first).round_s },
        matches: rounds.map { |round| present_collection(matches[round]).map(&:bracket_data) },
        teams:   rosters.transform_values { |roster| present(roster).bracket_data },
      }.to_json.html_safe
      # rubocop:enable Rails/OutputSafety
    end
  end
end
