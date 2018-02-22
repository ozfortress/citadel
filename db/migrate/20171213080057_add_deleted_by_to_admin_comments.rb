class AddDeletedByToAdminComments < ActiveRecord::Migration[5.0]
  def change
    add_column :user_comments, :deleted_at,    :datetime, null: true
    add_column :user_comments, :deleted_by_id, :integer,  null: true, index: true

    add_foreign_key :user_comments, :users, column: :deleted_by_id

    add_column :league_roster_comments, :deleted_at,    :datetime, null: true
    add_column :league_roster_comments, :deleted_by_id, :integer,  null: true, index: true

    add_foreign_key :league_roster_comments, :users, column: :deleted_by_id
  end
end
