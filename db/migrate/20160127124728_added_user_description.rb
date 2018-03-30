class AddedUserDescription < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :description, :text, null: false, default: ''
  end
end
