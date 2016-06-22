module Leagues
  module TransferPermissions
    extend ActiveSupport::Concern
    include RosterPermissions

    def user_can_manage_transfers?
      (user_can_edit_roster? && !@competition.roster_locked?) ||
        user_can_edit_league?
    end
  end
end
