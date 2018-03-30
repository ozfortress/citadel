class AddDisbandsionToCompetitionRosters < ActiveRecord::Migration[4.2]
  def change
    add_column :competition_rosters, :disbanded, :boolean, null: false, default: false
  end
end
