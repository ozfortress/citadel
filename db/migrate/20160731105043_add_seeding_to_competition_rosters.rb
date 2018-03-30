class AddSeedingToCompetitionRosters < ActiveRecord::Migration[4.2]
  def change
    add_column :competition_rosters, :seeding, :integer, null: true, default: nil
  end
end
