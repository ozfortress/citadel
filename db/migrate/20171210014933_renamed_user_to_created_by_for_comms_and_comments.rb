class RenamedUserToCreatedByForCommsAndComments < ActiveRecord::Migration[5.0]
  def change
    rename_column :league_match_comms, :user_id, :created_by_id
    rename_column :league_match_comm_edits, :user_id, :created_by_id
    rename_column :league_roster_comments, :user_id, :created_by_id
  end
end
