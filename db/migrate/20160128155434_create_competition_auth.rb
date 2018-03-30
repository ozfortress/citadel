require 'auth/migration_helper'

class CreateCompetitionAuth < ActiveRecord::Migration[4.2]
  include Auth::MigrationHelper

  def change
    add_action_auth :user, :edit, :competition
    add_action_auth :user, :edit, :competitions
  end
end
