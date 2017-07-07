class AddPointsSpecificToForfeits < ActiveRecord::Migration[5.0]
  def change
    add_column :leagues, :points_per_forfeit_win,  :integer, null: false, default: 2
    add_column :leagues, :points_per_forfeit_draw, :integer, null: false, default: 1
    add_column :leagues, :points_per_forfeit_loss, :integer, null: false, default: 0

    add_column :league_rosters, :forfeit_won_matches_count,   :integer, null: false, default: 0
    add_column :league_rosters, :forfeit_drawn_matches_count, :integer, null: false, default: 0
    add_column :league_rosters, :forfeit_lost_matches_count,  :integer, null: false, default: 0

    League::Roster.find_each do |roster|
      roster.update_match_counters!
    end

    reversible do |dir|
      dir.up do
        # Keep old behaviour for old leagues
        League.find_each do |league|
          league.points_per_forfeit_win = league.points_per_match_win
          # technical forfeits used to be counted as wins for both teams
          league.points_per_forfeit_draw = league.points_per_match_win
          league.points_per_forfeit_loss = league.points_per_match_loss
          league.save!
        end
      end
    end
  end
end
