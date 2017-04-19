class ChangeLeagueMatchPoints < ActiveRecord::Migration[5.0]
  def change
    change_column_default :leagues, :points_per_match_forfeit_loss, from: 1, to: 0

    rename_column :leagues, :points_per_match_forfeit_win,  :points_per_match_win
    rename_column :leagues, :points_per_match_forfeit_loss, :points_per_match_loss
    add_column :leagues, :points_per_match_draw, :integer, null: false, default: 0

    rename_column :leagues, :points_per_round_won,   :points_per_round_win
    rename_column :leagues, :points_per_round_drawn, :points_per_round_draw
    rename_column :leagues, :points_per_round_lost,  :points_per_round_loss
  end
end
