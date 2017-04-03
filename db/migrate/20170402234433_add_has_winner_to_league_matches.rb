class AddHasWinnerToLeagueMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :league_matches, :has_winner, :bool, null: false, default: false
    add_column :league_matches, :winner_id, :integer, null: true, default: nil
    add_foreign_key :league_matches, :league_rosters, column: :winner_id
  end
end
