class AddHideRostersOptionToLeagues < ActiveRecord::Migration[5.2]
  def change
    add_column :leagues, :hide_rosters, :boolean, null: false, default: false
  end
end
