module Leagues
  module TransferPermissions
    extend ActiveSupport::Concern
    include RosterPermissions

    def user_can_manage_transfers?(roster = nil)
      roster ||= @roster

      (user_can_edit_roster?(roster) && !roster.league.roster_locked?) ||
        user_can_edit_league?(roster.league)
    end
  end
end
