class AddAvatarsToUsersAndTeams < ActiveRecord::Migration
  def change
    add_column :users, :avatar, :string
    add_column :teams, :avatar, :string
  end
end
