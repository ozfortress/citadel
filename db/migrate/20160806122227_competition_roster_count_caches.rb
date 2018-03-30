class CompetitionRosterCountCaches < ActiveRecord::Migration[4.2]
  def change
    add_column :competition_rosters, :won_sets_count,             :integer, default: 0, null: false
    add_column :competition_rosters, :drawn_sets_count,           :integer, default: 0, null: false
    add_column :competition_rosters, :lost_sets_count,            :integer, default: 0, null: false
    add_column :competition_rosters, :forfeit_won_matches_count,  :integer, default: 0, null: false
    add_column :competition_rosters, :forfeit_lost_matches_count, :integer, default: 0, null: false

    CompetitionRoster.all.each do |roster|
      roster.update_match_counters!
    end
  end
end
