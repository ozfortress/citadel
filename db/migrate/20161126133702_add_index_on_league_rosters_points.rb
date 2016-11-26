class AddIndexOnLeagueRostersPoints < ActiveRecord::Migration[5.0]
  def change
    add_index :league_rosters, :points
  end
end
