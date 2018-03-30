require 'auth/migration_helper'

class CreatePermissionsAuth < ActiveRecord::Migration[4.2]
  include Auth::MigrationHelper

  def change
    add_action_auth :user, :edit, :permissions
  end
end
