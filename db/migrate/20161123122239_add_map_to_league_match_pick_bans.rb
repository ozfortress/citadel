class AddMapToLeagueMatchPickBans < ActiveRecord::Migration[5.0]
  def change
    add_column :league_match_pick_bans, :map_id, :integer, null: true
    add_index :league_match_pick_bans, :map_id
    add_foreign_key :league_match_pick_bans, :maps, column: :map_id
  end
end
