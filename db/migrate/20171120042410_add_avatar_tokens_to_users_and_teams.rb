class AddAvatarTokensToUsersAndTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :avatar_token, :string
    add_column :teams, :avatar_token, :string
  end
end
