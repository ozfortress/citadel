class CreateForumsAuth < ActiveRecord::Migration[5.0]
  include Auth::MigrationHelper

  def change
    add_action_auth :user, :manage, :forums
  end
end
