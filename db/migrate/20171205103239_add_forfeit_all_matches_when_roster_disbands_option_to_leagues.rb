class AddForfeitAllMatchesWhenRosterDisbandsOptionToLeagues < ActiveRecord::Migration[5.0]
  def change
    add_column :leagues, :forfeit_all_matches_when_roster_disbands, :boolean, null: false, default: true
  end
end
