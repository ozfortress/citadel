class AddMatcheRestrictionsToCompetitions < ActiveRecord::Migration
  def change
    add_column :competitions, :matches_submittable, :boolean, null: false, default: false
  end
end
