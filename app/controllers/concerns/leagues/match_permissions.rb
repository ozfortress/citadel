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

    def user_can_confirm_score?
      status = @match.status

      user_can_home_team? && status == 'submitted_by_away_team' ||
        user_can_away_team? && status == 'submitted_by_home_team'
    end

    def user_can_submit_team_score?
      @match.status == 'pending' && (user_can_home_team? || user_can_away_team?)
    end
  end
end
