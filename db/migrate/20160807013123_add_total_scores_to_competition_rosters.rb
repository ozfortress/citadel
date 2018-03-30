class AddTotalScoresToCompetitionRosters < ActiveRecord::Migration[4.2]
  def change
    add_column :competition_rosters, :total_scores, :integer, default: 0, null: false

    CompetitionRoster.all.each do |roster|
      roster.update_match_counters!
    end
  end
end
