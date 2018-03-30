class RemoveCompetitionRestrictions < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :min_players, :integer, null: false, default: 6
    add_column :competitions, :max_players, :integer, null: false, default: 0

    remove_column :divisions, :min_teams
    remove_column :divisions, :max_teams
    remove_column :divisions, :min_players
    remove_column :divisions, :max_players
  end
end
