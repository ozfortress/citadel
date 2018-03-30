class AddOptionToCompetitionsForAllowingDisbanding < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :allow_disbanding, :boolean, null: false, default: false
  end
end
