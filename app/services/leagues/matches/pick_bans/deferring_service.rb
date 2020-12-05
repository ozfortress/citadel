module Leagues
  module Matches
    module PickBans
      module DeferringService
        include BaseService

        def call(pick_ban, user)
          kind = pick_ban.kind

          pick_ban.transaction do
            pick_ban.defer!(user)

            notify_captains!(pick_ban, kind)
          end
        end

        private

        def notify_captains!(pick_ban, kind)
          msg = "#{pick_ban.roster.name} deferred their map #{kind}"
          link = match_path(pick_ban.match)

          User.which_can(:edit, pick_ban.other_roster.team).each do |captain|
            Users::NotificationService.call(captain, message: msg, link: link)
          end
        end
      end
    end
  end
end
