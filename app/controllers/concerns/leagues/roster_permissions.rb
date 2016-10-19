module Leagues
  module RosterPermissions
    extend ActiveSupport::Concern
    include ::LeaguePermissions

    def user_can_edit_roster?(roster = nil)
      roster ||= @roster
      disbanded = roster && roster.disbanded?

      user_can_edit_league?(roster.league) ||
        user_signed_in? && current_user.can?(:edit, roster.team) && !disbanded
    end

    def user_can_disband_roster?(roster = nil)
      roster ||= @roster

      user_can_edit_league?(roster.league) || (
        user_can_edit_roster?(roster) && roster.league.allow_disbanding?)
    end

    def user_can_destroy_roster?(roster = nil)
      roster ||= @roster

      user_can_edit_league?(roster.league) && roster.matches.empty?
    end
  end
end
