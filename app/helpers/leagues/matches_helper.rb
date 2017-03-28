module Leagues
  module MatchesHelper
    include MatchPermissions
    include Matches::PickBanPermissions

    def division_select
      options_from_collection_for_select(@league.divisions, :id, :name, @division.id)
    end

    def tournament_systems
      League::Division::TOURNAMENT_SYSTEMS
    end

    def tournament_system_select
      options = tournament_systems.map { |system| [system.to_s.titleize, system] }

      options_for_select options, @tournament_system
    end

    def swiss_pairers
      League::Division::SWISS_PAIRERS
    end

    def swiss_parer_select
      options = swiss_pairers.map { |pairer| [pairer.to_s.titleize, pairer] }

      options_for_select options, @swiss_tournament[:pairer]
    end

    def verify_rosters_link(match)
      params = { link: match_url(match) }

      "https://verify.ozfortress.com?#{params.to_param}"
    end
  end
end
