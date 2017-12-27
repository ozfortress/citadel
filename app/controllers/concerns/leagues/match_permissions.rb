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
      user_can_edit_league? || (
        @match.status == 'pending' &&
        (user_can_home_team? || user_can_away_team?) &&
        @league.matches_submittable)
    end

    def user_can_comm?
      !@match.bye? && user_signed_in? && user_not_banned? &&
        (@match.home_team.on_roster?(current_user) ||
         @match.away_team.on_roster?(current_user) ||
         user_can_either_teams?)
    end

    def user_can_edit_comm?(comm)
      user_can_edit_league? || (current_user == comm.created_by && user_not_banned?)
    end

    private

    def user_not_banned?
      current_user.can?(:use, :leagues) && current_user.can?(:use, :teams)
    end
  end
end
