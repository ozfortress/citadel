class AddForfeitByToCompetitionMatches < ActiveRecord::Migration[4.2]
  def change
    add_column :competition_matches, :forfeit_by, :integer, null: false, default: 0
  end
end
