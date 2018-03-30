require 'auth/migration_helper'

class CreateUsersAuth < ActiveRecord::Migration[4.2]
  include Auth::MigrationHelper

  def change
    add_action_auth :user, :edit, :users
  end
end
