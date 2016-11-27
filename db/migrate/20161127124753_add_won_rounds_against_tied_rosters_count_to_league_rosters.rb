class AddWonRoundsAgainstTiedRostersCountToLeagueRosters < ActiveRecord::Migration[5.0]
  def change
    add_column :league_rosters, :won_rounds_against_tied_rosters_count, :integer, default: 0, null: false

    League::Roster.all.each do |roster|
      roster.update_match_counters_tied!
    end
  end
end
