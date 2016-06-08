class AddOptionToCompetitionsForAllowingDisbanding < ActiveRecord::Migration
  def change
    add_column :competitions, :allow_disbanding, :boolean, null: false, default: false
  end
end
