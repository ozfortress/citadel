module Leagues
  module Matches
    module PickBans
      module DeferringService
        include BaseService

        def call(pick_ban, user)
          pick_ban.transaction do
            notify_captains!(pick_ban)

            pick_ban.defer!(user)
          end
        end

        private

        def notify_captains!(pick_ban)
          msg = "#{pick_ban.other_roster.name} deferred their map #{pick_ban.kind}"
          link = match_path(pick_ban.match)

          User.which_can(:edit, pick_ban.roster.team).each do |captain|
            Users::NotificationService.call(captain, msg, link)
          end
        end
      end
    end
  end
end
