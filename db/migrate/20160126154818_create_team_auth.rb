require 'auth/migration_helper'

class CreateTeamAuth < ActiveRecord::Migration
  include AuthMigrationHelper

  def change
    add_action_auth :user, :edit, :team, states: 2
    add_action_auth :user, :edit, :teams
  end
end
