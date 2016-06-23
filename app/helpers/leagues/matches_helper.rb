module Leagues
  module MatchesHelper
    include MatchPermissions

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
