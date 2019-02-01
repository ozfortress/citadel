class ChangeLeagueRostersPlacementNullability < ActiveRecord::Migration[5.2]
  def change
    change_column_null :league_rosters, :placement, 0
  end
end
