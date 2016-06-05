module Leagues
  module MatchesHelper
    include MatchPermissions

    def teams_select(div)
      div.active_rosters.map do |roster|
        [roster.name, roster.id]
      end
    end

    def maps_select
      Map.all.map do |map|
        [map.to_s, map.id]
      end
    end

    def generation_select
      options_for_select [['Swiss', :swiss], ['Round Robin', :round_robin]], @kind
    end
  end
end
