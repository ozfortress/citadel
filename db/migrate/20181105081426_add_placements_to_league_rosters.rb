class AddPlacementsToLeagueRosters < ActiveRecord::Migration[5.2]
  def change
    add_column :league_rosters, :placement, :integer

    reversible do |dir|
      dir.up do
        League::Roster.find_each do |roster|
          roster.update_match_counters!
        end
      end
    end
  end
end
