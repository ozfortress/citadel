module Leagues
  module Transfers
    module DenialService
      include BaseService
      extend CompletionMessageServicer

      def call(request)
        request.transaction do
          user   = request.user
          roster = request.roster
          notify_users(request, user, roster)
          notify_captains(request, user, roster)

          request.deny || rollback!
        end
      end

      private

      def message(transfer_msg)
        "The request to transfer #{transfer_msg} has been denied."
      end
    end
  end
end
