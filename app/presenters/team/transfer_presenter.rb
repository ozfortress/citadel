class Team
  class TransferPresenter < BasePresenter
    presents :transfer

    def user
      @user = present(transfer.user)
    end

    def team
      @team = present(transfer.team)
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

    def listing_with_implied_user
      out = if transfer.is_joining?
              h 'Joined '
            else
              h 'Left '
            end
      out += team.link
      out + " on #{transfer.created_at.strftime('%c')}"
    end
  end
end
