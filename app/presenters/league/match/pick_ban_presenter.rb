class League
  class Match
    class PickBanPresenter < BasePresenter
      presents :pick_ban

      def team
        present(if pick_ban.home_team?
                  pick_ban.match.home_team
                else
                  pick_ban.match.away_team
                end)
      end

      def picked_by
        @picked_by ||= present(pick_ban.picked_by)
      end

      def map
        @map ||= present(pick_ban.map)
      end

      def status
        if pick_ban.pending?
          safe_join([team.link, pending_kind, deferrable_message], ' ')
        elsif pick_ban.deferred?
          safe_join([team.link, ' (', picked_by.link, ') deferred their ', completed_kind_noun])
        else
          safe_join([team.link, ' (', picked_by.link, ') ', completed_kind_verb, ' ', map.link])
        end
      end

      private

      def completed_kind_verb
        if pick_ban.pick?
          'picked'
        else
          'banned'
        end
      end

      def completed_kind_noun
        if pick_ban.pick?
          'pick'
        else
          'ban'
        end
      end

      def pending_kind
        if pick_ban.pick?
          'picks'
        else
          'bans'
        end
      end

      def deferrable_message
        if pick_ban.deferrable?
          '(can defer)'
        else
          ''
        end
      end
    end
  end
end
