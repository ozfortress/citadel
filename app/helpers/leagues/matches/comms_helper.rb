module Leagues
  module Matches
    module CommsHelper
      include MatchPermissions
      include Matches::PickBanPermissions
    end
  end
end
