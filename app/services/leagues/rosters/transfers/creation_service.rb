module Leagues
  module Rosters
    module Transfers
      module CreationService
        include BaseService

        def call(roster, params)
          request = roster.transfer_requests.new(params)

          request.transaction do
            # Allow creating transfer requests for joining, if a player is already leaving
            destroy_leaving_requests(request)

            save_or_approve(request, roster)
          end

          request
        end

        private

        def destroy_leaving_requests(request)
          requests = request.league.transfer_requests.pending

          requests.where(user: request.user, is_joining: false).destroy_all
        end

        def save_or_approve(request, roster)
          user = request.user

          if roster.league.transfers_require_approval?
            request.save || rollback!

            request_notify_user(request, user, roster)
          else
            request.approve || rollback!

            transfer_notify_user(request, user, roster)
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
          link = team_path(roster.team)

          Users::NotificationService.call(user, msg, link)
        end

        def transfer_notify_user(request, user, roster)
          msg = "You have been transferred #{request_msg(request)} "\
                "#{roster.name} for #{roster.league.name}"
          link = team_path(roster.team)

          Users::NotificationService.call(user, msg, link)
        end
      end
    end
  end
end
