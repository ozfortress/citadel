class AddScheduleLockToLeagues < ActiveRecord::Migration[5.0]
  def change
    add_column :leagues, :schedule_locked, :boolean, null: false, default: false
  end
end
