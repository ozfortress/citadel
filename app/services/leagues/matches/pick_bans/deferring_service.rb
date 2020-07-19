module Leagues
  module Matches
    module PickBans
      module DeferringService
        include BaseService

        def call(pick_ban, user)
          old_pick_ban = pick_ban.dup
          pick_ban.transaction do
            pick_ban.defer!(user)

            notify_captains!(old_pick_ban)
          end
        end

        private

        def notify_captains!(pick_ban)
          msg = "#{pick_ban.other_roster.name} deferred their map #{pick_ban.kind}"
          link = match_path(pick_ban.match)

          User.which_can(:edit, pick_ban.roster.team).each do |captain|
            Users::NotificationService.call(captain, message: msg, link: link)
          end
        end
      end
    end
  end
end
