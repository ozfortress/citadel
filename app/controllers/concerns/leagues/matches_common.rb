module Leagues
  module MatchesCommon
    extend ActiveSupport::Concern
    include MatchPermissions

    def match_show_includes
      @pick_bans = @match.pick_bans.includes(:map)
      @rounds    = @match.rounds.includes(:map)

      @comms = @match.comms.order(:created_at).includes(:user)

      match_show_permissions_includes
    end

    def match_show_permissions_includes
      home_team_permissions = User.permissions(@match.home_team.users.load)
      home_team_permissions.fetch(:edit, @match.home_team.team)
      home_team_permissions.fetch(:use, @match.home_team.team)

      away_team_permissions = User.permissions(@match.away_team.users.load)
      away_team_permissions.fetch(:edit, @match.away_team.team)
      away_team_permissions.fetch(:use, @match.away_team.team)
    end
  end
end
