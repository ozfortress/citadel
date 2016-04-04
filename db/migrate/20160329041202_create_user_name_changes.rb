class CreateUserNameChanges < ActiveRecord::Migration
  def change
    create_table :user_name_changes do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.integer :approved_by_id
      t.integer :denied_by_id

      t.string :name

      t.timestamps null: false
    end

    add_index :user_name_changes, :approved_by_id
    add_foreign_key :user_name_changes, :users, column: :approved_by_id
    add_index :user_name_changes, :denied_by_id
    add_foreign_key :user_name_changes, :users, column: :denied_by_id
  end
end
