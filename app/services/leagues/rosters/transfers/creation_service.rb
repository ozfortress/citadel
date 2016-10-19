module Leagues
  module Rosters
    module Transfers
      module CreationService
        include BaseService

        def call(roster, params)
          request = roster.transfer_requests.new(params)

          request.transaction do
            save_or_approve(request, roster)
          end

          request
        end

        private

        def save_or_approve(request, roster)
          if roster.league.transfers_require_approval?
            request.save || rollback!

            request_notify_user(request, request.user, roster)
          else
            request.approve || rollback!

            transfer_notify_user(request, request.user, roster)
          end
        end

        def request_msg(request)
          if request.is_joining?
            'into'
          else
            'out of'
          end
        end

        def request_notify_user(request, user, roster)
          msg = "It has been requested for you to transfer #{request_msg(request)} "\
                "#{roster.name} for #{roster.league.name}"
          link = league_roster_path(roster.league, roster)

          Users::NotificationService.call(user, msg, link)
        end

        def transfer_notify_user(request, user, roster)
          msg = "You have been transferred #{request_msg(request)} "\
                "#{roster.name} for #{roster.league.name}"
          link = league_roster_path(roster.league, roster)

          Users::NotificationService.call(user, msg, link)
        end
      end
    end
  end
end
