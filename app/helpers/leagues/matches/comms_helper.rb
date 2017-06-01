module Leagues
  module Matches
    module CommsHelper
      include MatchPermissions
      include MatchesHelper
      include Matches::PickBanPermissions
    end
  end
end
