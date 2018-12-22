class League
  class DivisionPresenter < BasePresenter
    presents :division

    def bracket_data(rosters, matches)
      rosters = rosters.index_by(&:id)
      matches = matches.group_by(&:round_number)
      rounds  = matches.keys.sort

      {
        rounds:  rounds.map { |round| html_escape present(matches[round].first).round_s },
        matches: rounds.map { |round| present_collection(matches[round]).map(&:bracket_data) },
        teams:   rosters.map { |k, roster| [k, present(roster).bracket_data] }.to_h,
      }.to_json
    end
  end
end
