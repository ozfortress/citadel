class AddRoundNameToLeagueMatches < ActiveRecord::Migration[5.0]
  def change
    rename_column :league_matches, :round, :round_number
    add_column :league_matches, :round_name, :string, default: "", null: false
  end
end
