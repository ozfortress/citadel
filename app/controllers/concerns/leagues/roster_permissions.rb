module Leagues
  module RosterPermissions
    extend ActiveSupport::Concern
    include ::LeaguePermissions

    def user_can_edit_roster?(options = {})
      team = options[:team] || @roster.team

      user_can_edit_league? ||
        user_signed_in? && current_user.can?(:edit, team)
    end
  end
end
