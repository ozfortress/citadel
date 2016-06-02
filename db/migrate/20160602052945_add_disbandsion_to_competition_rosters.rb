class AddDisbandsionToCompetitionRosters < ActiveRecord::Migration
  def change
    add_column :competition_rosters, :disbanded, :boolean, null: false, default: false
  end
end
