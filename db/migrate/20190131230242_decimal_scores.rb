class DecimalScores < ActiveRecord::Migration[5.2]
  def change
    change_column :leagues, :points_per_round_win, :decimal
    change_column :leagues, :points_per_round_draw, :decimal
    change_column :leagues, :points_per_round_loss, :decimal
    change_column :leagues, :points_per_match_loss, :decimal
    change_column :leagues, :points_per_match_win, :decimal
    change_column :leagues, :points_per_match_draw, :decimal
    change_column :leagues, :points_per_forfeit_win, :decimal
    change_column :leagues, :points_per_forfeit_draw, :decimal
    change_column :leagues, :points_per_forfeit_loss, :decimal

    change_column :league_rosters, :points, :decimal
    change_column :league_rosters, :total_scores, :decimal
  end
end
