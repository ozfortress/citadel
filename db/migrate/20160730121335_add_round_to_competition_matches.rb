class AddRoundToCompetitionMatches < ActiveRecord::Migration[4.2]
  def change
    add_column :competition_matches, :round, :integer, null: true, default: nil
  end
end
