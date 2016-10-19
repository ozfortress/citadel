class Team
  class TransferPresenter < ActionPresenter::Base
    presents :transfer

    def listing
      out = present(transfer.user).link
      out += if transfer.is_joining?
               ' joined the team'
             else
               ' left the team'
             end
      out + " on #{transfer.created_at.strftime('%c')}"
    end
  end
end
