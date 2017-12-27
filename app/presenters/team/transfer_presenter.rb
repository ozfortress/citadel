class Team
  class TransferPresenter < BasePresenter
    presents :transfer

    def user
      @user = present(transfer.user)
    end

    def listing
      out = user.link
      out += if transfer.is_joining?
               ' joined the team'
             else
               ' left the team'
             end
      out + " on #{transfer.created_at.strftime('%c')}"
    end
  end
end
