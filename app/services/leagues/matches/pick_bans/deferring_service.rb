module Leagues
  module Matches
    module PickBans
      module DeferringService
        include BaseService

        def call(pick_ban)
          pick_ban.transaction do
            pick_ban.defer!

            notify_captains!(pick_ban)
          end
        end

        private

        def notify_captains!(pick_ban)
          msg = "#{pick_ban.other_roster.name} deferred their #{pick_ban.kind}"
          link = match_path(pick_ban.match)

          User.get_revokeable(:edit, pick_ban.roster.team).each do |captain|
            Users::NotificationService.call(captain, msg, link)
          end
        end
      end
    end
  end
end
