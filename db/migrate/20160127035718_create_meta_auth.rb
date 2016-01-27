require 'auth/migration_helper'

class CreateMetaAuth < ActiveRecord::Migration
  include Auth::MigrationHelper

  def change
    add_action_auth :user, :edit, :games
  end
end
