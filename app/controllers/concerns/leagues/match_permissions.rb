module Leagues
  module MatchPermissions
    extend ActiveSupport::Concern
    include ::LeaguePermissions

    def user_can_comms?
      user_signed_in? && (user_can_edit_league? ||
                          current_user.can?(:edit, @match.home_team.team) ||
                          current_user.can?(:edit, @match.away_team.team))
    end
  end
end
