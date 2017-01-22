require 'auth/migration_helper'

class AddBansToUsers < ActiveRecord::Migration[5.0]
  include Auth::MigrationHelper

  def change
    add_action_ban(:user, :use, :users)
    add_action_ban(:user, :use, :teams)
    add_action_ban(:user, :use, :leagues)

    add_action_ban(:user, :use, :forums)
    add_action_ban(:user, :use, :forums_topic)
    add_action_ban(:user, :use, :forums_thread)
  end
end
