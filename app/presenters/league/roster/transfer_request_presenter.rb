class League
  class Roster
    class TransferRequestPresenter < ActionPresenter::Base
      presents :transfer_request

      def transfer_message
        if transfer_request.is_joining?
          "pending transfer to '#{present(transfer_request.roster).link}'".html_safe
        else
          "pending transfer out of '#{present(transfer_request.roster).link}'".html_safe
        end
      end
    end
  end
end
