class AddScheduleOptionToLeagues < ActiveRecord::Migration[5.0]
  def change
    add_column :leagues, :schedule, :integer, default: 0, null: false
  end
end
