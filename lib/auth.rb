require 'auth/model'
require 'auth/migration_helper'

module Auth
  def self.grant_name(actor, action, subject)
    "action_#{actor}_#{action}_#{subject}"
  end

  def self.ban_name(actor, action, subject)
    "action_#{actor}_#{action}_#{subject}_bans"
  end
end
