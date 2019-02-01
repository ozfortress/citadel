class AddTotalOpponentCounts < ActiveRecord::Migration[5.2]
  def change
    add_column :league_matches, :total_home_team_round_wins, :integer, null: false, default: 0
    add_column :league_matches, :total_away_team_round_wins, :integer, null: false, default: 0
    add_column :league_matches, :total_round_draws, :integer, null: false, default: 0

    add_column :league_rosters, :bye_matches_count, :integer, null: false, default: 0
    add_column :league_rosters, :normalized_round_score, :decimal, null: false, default: 0
    add_column :league_rosters, :buchholz_score, :decimal, null: false, default: 0
    add_column :league_rosters, :median_buchholz_score, :decimal, null: false, default: 0

    reversible do |dir|
      dir.up do
        League::Match.includes(:rounds).find_each { |match| match.reset_cache! }

        League.find_each { |league| league.trigger_scores_update! }
      end
    end
  end
end
