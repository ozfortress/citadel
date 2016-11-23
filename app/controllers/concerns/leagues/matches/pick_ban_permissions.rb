module Leagues
  module Matches
    module PickBanPermissions
      extend ActiveSupport::Concern
      include ::Leagues::MatchPermissions

      def user_can_submit_pick_ban?
        if @pick_ban.home_team?
          user_can_home_team?
        else
          user_can_away_team?
        end || user_can_edit_league?
      end
    end
  end
end
