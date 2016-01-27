class AddedUserDescription < ActiveRecord::Migration
  def change
    add_column :users, :description, :text, null: false, default: ''
  end
end
