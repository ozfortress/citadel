module Leagues
  module MatchesHelper
    include MatchPermissions
    include Matches::PickBanPermissions

    def generation_select
      options_for_select [['Swiss', :swiss], ['Round Robin', :round_robin]], @kind
    end

    def verify_rosters_link(match)
      params = { link: match_url(match) }

      "https://verify.ozfortress.com?#{params.to_param}"
    end
  end
end
