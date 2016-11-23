class League
  class Match
    class PickBanPresenter < ActionPresenter::Base
      presents :pick_ban

      def team
        present(if pick_ban.home_team?
                  pick_ban.match.home_team
                else
                  pick_ban.match.away_team
                end)
      end

      def map_link
        link_to pick_ban.map.name, meta_map_path(pick_ban.map)
      end

      def status
        team.link + if pick_ban.pending?
                      " #{pending_kind}"
                    else
                      " #{completed_kind} ".html_safe + map_link
                    end
      end

      private

      def completed_kind
        if pick_ban.pick?
          'picked'
        else
          'banned'
        end
      end

      def pending_kind
        if pick_ban.pick?
          'picks'
        else
          'bans'
        end
      end
    end
  end
end
