class AddSeedingToCompetitionRosters < ActiveRecord::Migration
  def change
    add_column :competition_rosters, :seeding, :integer, null: true, default: nil
  end
end
