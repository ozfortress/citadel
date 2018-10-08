class ChangeLeagueMatchesRoundNumberNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :league_matches, :round_number, false, 1
    change_column_default :league_matches, :round_number, 1, from: nil
  end
end
