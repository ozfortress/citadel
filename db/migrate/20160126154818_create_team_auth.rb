require 'auth/migration_helper'

class CreateTeamAuth < ActiveRecord::Migration[4.2]
  include Auth::MigrationHelper

  def change
    add_action_auth :user, :edit, :team
    add_action_auth :user, :edit, :teams
  end
end
