require 'auth/migration_helper'

class CreateUsersAuth < ActiveRecord::Migration
  include Auth::MigrationHelper

  def change
    add_action_auth :user, :edit, :users
  end
end
