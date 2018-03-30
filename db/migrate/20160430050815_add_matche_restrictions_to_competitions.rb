class AddMatcheRestrictionsToCompetitions < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :matches_submittable, :boolean, null: false, default: false
  end
end
