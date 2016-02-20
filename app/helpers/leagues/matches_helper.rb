module Leagues
  module MatchesHelper
    include LeaguePermissions

    def teams_select(div)
      div.rosters.map do |roster|
        [roster.to_s, roster.id]
      end
    end

    def maps_select
      Map.all.map do |map|
        [map.to_s, map.id]
      end
    end
  end
end
