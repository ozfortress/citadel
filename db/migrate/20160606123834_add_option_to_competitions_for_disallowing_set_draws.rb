class AddOptionToCompetitionsForDisallowingSetDraws < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :allow_set_draws, :boolean, null: false, default: true
  end
end
