class TableNameRefactor < ActiveRecord::Migration[4.2]
  def change
    rename_table :competitions,                :leagues
    rename_table :competition_match_comms,     :league_match_comms
    rename_table :competition_sets,            :league_match_rounds
    rename_table :competition_roster_comments, :league_roster_comments
    rename_table :competition_transfers,       :league_roster_transfers
    rename_table :divisions,                   :league_divisions
    rename_table :competition_matches,         :league_matches
    rename_table :competition_rosters,         :league_rosters
    rename_table :competition_tiebreakers,     :league_tiebreakers
    rename_table :transfers,                   :team_transfers
    rename_table :notifications,               :user_notifications
    rename_table :titles,                      :user_titles

    rename_column :league_divisions,        :competition_id,        :league_id
    rename_column :league_match_comms,      :competition_match_id,  :match_id
    rename_column :league_match_rounds,     :competition_match_id,  :match_id
    rename_column :league_roster_comments,  :competition_roster_id, :roster_id
    rename_column :league_roster_transfers, :competition_roster_id, :roster_id
    rename_column :league_tiebreakers,      :competition_id,        :league_id
    rename_column :user_titles,             :competition_id,        :league_id
    rename_column :user_titles,             :competition_roster_id, :roster_id
    rename_column :league_rosters,          :won_sets_count,        :won_rounds_count
    rename_column :league_rosters,          :drawn_sets_count,      :drawn_rounds_count
    rename_column :league_rosters,          :lost_sets_count,       :lost_rounds_count

    rename_table :action_user_edit_competition,            :action_user_edit_league
    rename_table :action_user_edit_competitions,           :action_user_edit_leagues
    rename_table :action_user_manage_rosters_competition,  :action_user_manage_rosters_league
    rename_table :action_user_manage_rosters_competitions, :action_user_manage_rosters_leagues

    rename_column :action_user_edit_league,           :competition_id, :league_id
    rename_column :action_user_manage_rosters_league, :competition_id, :league_id
  end
end
