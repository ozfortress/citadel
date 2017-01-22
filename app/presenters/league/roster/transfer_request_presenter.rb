class League
  class Roster
    class TransferRequestPresenter < ActionPresenter::Base
      presents :transfer_request

      def user
        @user ||= present(transfer_request.user)
      end

      def listing
        elements = [transfer_request.created_at.strftime('%c'), user.link,
                    user.roster_status(transfer_request.league), transfer_message]
        safe_join(elements, ' ')
      end

      def transfer_message
        if transfer_request.is_joining?
          safe_join(["pending transfer to '", present(transfer_request.roster).link, "'"])
        else
          safe_join(["pending transfer out of '", present(transfer_request.roster).link, "'"])
        end
      end
    end
  end
end
