class AddCustomBadgesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :badge_name, :string, null: false, default: ''
    add_column :users, :badge_color, :integer, null: false, default: 0
  end
end
