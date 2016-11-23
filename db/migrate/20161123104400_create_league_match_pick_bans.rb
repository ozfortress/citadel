class CreateLeagueMatchPickBans < ActiveRecord::Migration[5.0]
  def change
    create_table :league_match_pick_bans do |t|
      t.integer :match_id,     null: false, index: true
      t.integer :picked_by_id, null: true

      t.integer :kind, null: false, limit: 1
      t.integer :team, null: false, limit: 1

      t.timestamps null: false
    end

    add_foreign_key :league_match_pick_bans, :league_matches, column: :match_id
    add_foreign_key :league_match_pick_bans, :users, column: :picked_by_id
  end
end
