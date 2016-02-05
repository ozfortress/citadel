class CreateCompetitionRostersAuth < ActiveRecord::Migration
  include Auth::MigrationHelper

  def change
    add_action_auth :user, :manage_rosters, :competition
    add_action_auth :user, :manage_rosters, :competitions
  end
end
