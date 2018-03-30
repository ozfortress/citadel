class AddDivisionLimitations < ActiveRecord::Migration[4.2]
  def change
    add_column :divisions, :min_teams,   :integer, null: false
    add_column :divisions, :max_teams,   :integer, null: false
    add_column :divisions, :min_players, :integer, null: false
    add_column :divisions, :max_players, :integer, null: false
  end
end
