module Leagues
  module Rosters
    module Transfers
      module CancellationService
        include BaseService

        def call(request, roster)
          request.transaction do
            request.cancel || rollback!

            notify_user(request, request.user, roster)
          end

          request.destroyed?
        end

        private

        def request_msg(request)
          if request.is_joining?
            'into'
          else
            'out of'
          end
        end

        def notify_user(request, user, roster)
          msg = "The request for you to transfer #{request_msg(request)} "\
                "#{roster.name} for #{roster.league.name} has been cancelled"
          link = team_path(roster.team)

          Users::NotificationService.call(user, message: msg, link: link)
        end
      end
    end
  end
end
