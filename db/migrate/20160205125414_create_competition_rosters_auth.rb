class CreateCompetitionRostersAuth < ActiveRecord::Migration[4.2]
  include Auth::MigrationHelper

  def change
    add_action_auth :user, :manage_rosters, :competition
    add_action_auth :user, :manage_rosters, :competitions
  end
end
