class League
  class Roster
    class TransferPresenter < BasePresenter
      presents :transfer

      def user
        @user = present(transfer.user)
      end

      def roster
        @roster = present(transfer.roster)
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
        out += roster.link
        out + " in #{transfer.division.name} on #{transfer.created_at.strftime('%c')}"
      end
    end
  end
end
