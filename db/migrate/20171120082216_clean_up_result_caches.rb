class CleanUpResultCaches < ActiveRecord::Migration[5.0]
  def change
    change_column_default :league_match_rounds, :home_team_score, 0
    change_column_default :league_match_rounds, :away_team_score, 0

    add_column :league_match_rounds, :score_difference, :decimal, precision: 20, scale: 6, default: 0, null: false

    add_column :league_matches, :total_score_difference, :decimal, precision: 20, scale: 6, default: 0, null: false
    add_column :league_matches, :total_home_team_score,  :decimal, precision: 20, scale: 6, default: 0, null: false
    add_column :league_matches, :total_away_team_score,  :decimal, precision: 20, scale: 6, default: 0, null: false

    add_column :league_rosters, :total_score_difference, :decimal, precision: 20, scale: 6, default: 0, null: false

    add_column :league_matches, :allow_round_draws, :boolean, default: false, null: false

    reversible do |direction|
      direction.up do
        League::Match.find_each do |match|
          match.allow_round_draws = match.league.allow_round_draws
          begin
            match.save!
          rescue ActiveRecord::RecordInvalid
            match.allow_round_draws = !match.allow_round_draws
            match.save!
          end
        end

        # League::Match::Round.find_each { |round| round.reset_cache! }
        League::Match.find_each { |match| match.reset_cache! }
      end
    end

    remove_column :leagues, :allow_round_draws

    # Also add a bunch of indexes to make things faster
    add_index :league_match_rounds, :winner_id
    add_index :league_match_rounds, :loser_id
    add_index :league_matches, :loser_id
  end
end
