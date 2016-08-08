class RenameLeagueSetsToRounds < ActiveRecord::Migration
  def change
    rename_column :leagues, :allow_set_draws,      :allow_round_draws
    rename_column :leagues, :points_per_set_won,   :points_per_round_won
    rename_column :leagues, :points_per_set_drawn, :points_per_round_drawn
    rename_column :leagues, :points_per_set_lost,  :points_per_round_lost
  end
end
