module Leagues
  module Matches
    class PickBansController < ApplicationController
      include PickBanPermissions

      before_action only: :submit do
        @match = League::Match.find(params[:match_id])
        @league = @match.league
        @pick_ban = @match.pick_bans.pending.find(params[:id])
        @map = @match.map_pool.find(params[:pick_ban][:map_id])
      end
      before_action :require_can_submit, only: :submit

      def submit
        PickBans::SubmissionService.call(@pick_ban, current_user, @map)

        if @pick_ban.invalid?
          # TODO: Flash
        end

        redirect_to match_path(@match)
      end

      private

      def require_can_submit
        redirect_back(fallback_location: match_path(@match)) unless user_can_submit_pick_ban?
      end
    end
  end
end
