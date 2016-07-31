class AddRoundToCompetitionMatches < ActiveRecord::Migration
  def change
    add_column :competition_matches, :round, :integer, null: true, default: nil
  end
end
