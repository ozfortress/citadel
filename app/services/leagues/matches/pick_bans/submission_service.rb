module Leagues
  module Matches
    module PickBans
      module SubmissionService
        include BaseService

        def call(pick_ban, user, map)
          pick_ban.transaction do
            pick_ban.submit(user, map) || rollback!

            notify_captains!(pick_ban)
          end
        end

        private

        def captains_for(pick_ban)
          roster = if pick_ban.home_team?
                     pick_ban.match.away_team
                   else
                     pick_ban.match.home_team
                   end

          User.get_revokeable(:edit, roster.team)
        end

        def notify_captains!(pick_ban)
          msg = notification_message(pick_ban)
          link = match_path(pick_ban.match)

          captains_for(pick_ban).each do |captain|
            Users::NotificationService.call(captain, msg, link)
          end
        end

        def notification_message(pick_ban)
          "#{team_name(pick_ban)} #{completed_kind(pick_ban)} #{pick_ban.map}"
        end

        def completed_kind(pick_ban)
          if pick_ban.pick?
            'picked'
          else
            'banned'
          end
        end

        def team_name(pick_ban)
          if pick_ban.home_team?
            pick_ban.match.home_team.name
          else
            pick_ban.match.away_team.name
          end
        end
      end
    end
  end
end
