module Leagues
  module Matches
    class PickBansController < ApplicationController
      include PickBanPermissions

      before_action only: :submit do
        @pick_ban = League::Match::PickBan.find(params[:id])
        @match    = @pick_ban.match
        @league   = @match.league
        @map      = @match.map_pool.find(params[:pick_ban][:map_id])
      end
      before_action :require_pick_ban_pending, only: :submit
      before_action :require_can_submit, only: :submit

      def submit
        PickBans::SubmissionService.call(@pick_ban, current_user, @map)

        if @pick_ban.invalid?
          # TODO: Flash
        end

        redirect_to match_path(@match)
      end

      private

      def require_pick_ban_pending
        redirect_back(fallback_location: match_path(@match)) unless @pick_ban.pending?
      end

      def require_can_submit
        redirect_back(fallback_location: match_path(@match)) unless user_can_submit_pick_ban?
      end
    end
  end
end
