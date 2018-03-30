class AddAvatarsToUsersAndTeams < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :avatar, :string
    add_column :teams, :avatar, :string
  end
end
