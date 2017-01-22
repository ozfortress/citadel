module Leagues
  module RosterPermissions
    extend ActiveSupport::Concern
    include ::LeaguePermissions

    def user_can_sign_up?(league = nil, team = nil)
      league ||= @league
      team ||= @team

      user_signed_in? && league.signuppable? && user_not_banned? && user_has_signup_team?(team)
    end

    def user_can_edit_roster?(roster = nil)
      roster ||= @roster
      disbanded = roster && roster.disbanded?

      user_can_edit_league?(roster.league) ||
        user_signed_in? && current_user.can?(:edit, roster.team) && user_not_banned? && !disbanded
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

    private

    def user_can_sign_up_team?(league, team)
      !team.entered?(league) && current_user.can?(:edit, team)
    end

    def user_not_banned?
      current_user.can?(:use, :teams) && current_user.can?(:use, :leagues)
    end

    def user_has_signup_team?(team)
      if team
        user_can_sign_up_team?(league, team)
      else
        current_user.can?(:edit, :team)
      end
    end
  end
end
