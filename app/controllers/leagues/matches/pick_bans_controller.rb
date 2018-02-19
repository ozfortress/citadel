module Leagues
  module Matches
    class PickBansController < ApplicationController
      include PickBanPermissions

      before_action only: [:submit, :defer] do
        @pick_ban = League::Match::PickBan.find(params[:id])
        @match    = @pick_ban.match
        @league   = @match.league
      end
      before_action :require_can_pick_ban, only: [:submit, :defer]
      before_action :require_pick_ban_pending, only: [:submit, :defer]
      before_action :require_pick_ban_deferrable, only: :defer

      def submit
        @map = @match.map_pool.find(params[:pick_ban][:map_id])
        PickBans::SubmissionService.call(@pick_ban, current_user, @map)

        if @pick_ban.invalid?
          # TODO: Flash
        end

        redirect_to match_path(@match)
      end

      def defer
        PickBans::DeferringService.call(@pick_ban, current_user)

        redirect_to match_path(@match)
      end

      private

      def redirect_to_match
        redirect_back(fallback_location: match_path(@match))
      end

      def require_can_pick_ban
        redirect_to_match unless user_can_submit_pick_ban?
      end

      def require_pick_ban_pending
        redirect_to_match unless @pick_ban.pending?
      end

      def require_pick_ban_deferrable
        redirect_to_match unless @pick_ban.deferrable?
      end
    end
  end
end
