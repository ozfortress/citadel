class AddPlayersCountToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :players_count, :integer, default: 0, null: false

    Team.select(:id).find_each do |roster|
      Team.reset_counters(roster.id, :players)
    end
  end
end
