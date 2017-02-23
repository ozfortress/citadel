module Leagues
  module MatchesCommon
    extend ActiveSupport::Concern
    include MatchPermissions

    def match_show_includes
      @pick_bans = @match.pick_bans.includes(:map)
      @rounds    = @match.rounds.includes(:map)

      @comms = @match.comms.order(:created_at).includes(:user)
    end
  end
end
