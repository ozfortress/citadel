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
          msg = "#{pick_ban.roster.name} #{completed_kind(pick_ban)} #{pick_ban.map}"
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
