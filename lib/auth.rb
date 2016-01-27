require 'auth/permission'
require 'auth/migration_helper'

module Auth
  def self.auth_name(actor, action, subject)
    "action_#{actor}_#{action}_#{subject}"
  end
end
