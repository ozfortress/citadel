class AddForfeitByToCompetitionMatches < ActiveRecord::Migration
  def change
    add_column :competition_matches, :forfeit_by, :integer, null: false, default: 0
  end
end
