module Leagues
  module RosterPermissions
    extend ActiveSupport::Concern
    include ::LeaguePermissions

    def user_can_edit_roster?(options = {})
      team = options[:team] || @roster.team
      disbanded = @roster && @roster.disbanded?

      user_can_edit_league? ||
        user_signed_in? && current_user.can?(:edit, team) && !disbanded
    end

    def user_can_disband_roster?
      user_can_edit_league? || (user_can_edit_roster? &&
        (@league.allow_disbanding? || @league.signuppable?))
    end
  end
end
