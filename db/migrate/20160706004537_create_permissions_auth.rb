require 'auth/migration_helper'

class CreatePermissionsAuth < ActiveRecord::Migration
  include Auth::MigrationHelper

  def change
    add_action_auth :user, :edit, :permissions
  end
end
