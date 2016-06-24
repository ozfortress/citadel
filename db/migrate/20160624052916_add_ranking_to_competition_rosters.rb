class AddRankingToCompetitionRosters < ActiveRecord::Migration
  def change
    add_column :competition_rosters, :ranking, :integer, null: true
  end
end
