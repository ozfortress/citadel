class AddScheduleDataToLeagueRosters < ActiveRecord::Migration[5.0]
  def change
    add_column :league_rosters, :schedule_data, :json, null: true
  end
end
