class AddCompetitionPointsSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :points_per_set_won, :integer, null: false, default: 2
    add_column :competitions, :points_per_set_drawn, :integer, null: false, default: 1
    add_column :competitions, :points_per_set_lost, :integer, null: false, default: 0
    add_column :competitions, :points_per_match_forfeit_loss, :integer, null: false, default: 1
    add_column :competitions, :points_per_match_forfeit_win, :integer, null: false, default: 1
  end
end
