module Leagues
  module MatchPermissions
    extend ActiveSupport::Concern
    include ::LeaguePermissions

    def user_can_home_team?
      user_signed_in? && current_user.can?(:edit, @match.home_team.team)
    end

    def user_can_away_team?
      user_signed_in? && current_user.can?(:edit, @match.away_team.team)
    end

    def user_can_either_teams?
      user_can_edit_league? || user_can_home_team? || user_can_away_team?
    end

    def can_confirm_score?
      user_can_edit_league? ||
        user_can_home_team? && @match.status == 'submitted_by_away_team' ||
        user_can_away_team? && @match.status == 'submitted_by_home_team'
    end
  end
end
