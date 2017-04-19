class AddScriptStateToLeagueMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :league_matches, :script_state, :string, null: true, default: nil
  end
end
