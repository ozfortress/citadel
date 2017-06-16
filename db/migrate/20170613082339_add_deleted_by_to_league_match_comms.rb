class AddDeletedByToLeagueMatchComms < ActiveRecord::Migration[5.0]
  def change
    add_column :league_match_comms, :deleted_at, :datetime, null: true
    add_column :league_match_comms, :deleted_by_id, :integer, null: true, default: nil, index: true
    add_foreign_key :league_match_comms, :users, column: :deleted_by_id
  end
end
