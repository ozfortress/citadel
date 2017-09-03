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

        def notify_captains!(pick_ban)
          map = pick_ban.map
          roster = pick_ban.roster
          msg = "#{roster.name} #{completed_kind(pick_ban)} #{map.name}"
          link = match_path(pick_ban.match)

          User.which_can(:edit, pick_ban.other_roster.team).each do |captain|
            Users::NotificationService.call(captain, msg, link)
          end
        end

        def completed_kind(pick_ban)
          if pick_ban.pick?
            'picked'
          else
            'banned'
          end
        end
      end
    end
  end
end
