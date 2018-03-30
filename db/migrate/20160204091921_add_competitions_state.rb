class AddCompetitionsState < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :signuppable,   :boolean, null: false, default: false
    add_column :competitions, :roster_locked, :boolean, null: false, default: false
  end
end
