class AddOptionToCompetitionsForDisallowingSetDraws < ActiveRecord::Migration
  def change
    add_column :competitions, :allow_set_draws, :boolean, null: false, default: true
  end
end
