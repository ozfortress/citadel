class AddTeamCachesToMatchesAndRounds < ActiveRecord::Migration[5.0]
  def change
    add_index :league_matches, :winner_id

    add_column :league_matches, :loser_id, :integer, null: true, index: true, default: nil
    add_foreign_key :league_matches, :league_rosters, column: :loser_id

    add_column :league_match_rounds, :loser_id, :integer, null: true, index: true, default: nil
    add_foreign_key :league_match_rounds, :league_rosters, column: :loser_id

    add_column :league_match_rounds, :winner_id, :integer, null: true, index: true, default: nil
    add_foreign_key :league_match_rounds, :league_rosters, column: :winner_id

    add_column :league_match_rounds, :has_outcome, :bool, null: false, index: true, default: false

    rename_column :league_rosters, :forfeit_won_matches_count,  :won_matches_count
    rename_column :league_rosters, :forfeit_lost_matches_count, :lost_matches_count
    add_column :league_rosters, :drawn_matches_count, :integer, default: 0, null: false
  end
end
