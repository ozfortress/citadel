class AddRankingToCompetitionRosters < ActiveRecord::Migration[4.2]
  def change
    add_column :competition_rosters, :ranking, :integer, null: true
  end
end
