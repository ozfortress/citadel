class AddRostersCounterCacheToLeagues < ActiveRecord::Migration[4.2]
  def change
    add_column :leagues, :rosters_count, :integer, default: 0, null: false

    League.find_each do |league|
      league.update(rosters_count: league.rosters.count)
    end
  end
end
