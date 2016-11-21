module Leagues
  module MatchesHelper
    include MatchPermissions

    def generation_select
      options_for_select [['Swiss', :swiss], ['Round Robin', :round_robin]], @kind
    end
  end
end
