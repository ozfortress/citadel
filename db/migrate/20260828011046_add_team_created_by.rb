class AddTeamCreatedBy < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :created_by_id, :integer, null: true
    add_index :teams, :created_by_id
    add_foreign_key :teams, :users, column: :created_by_id
  end
end
