module Teams
  module Invites
    module AcceptanceService
      include BaseService

      def call(invite)
        invite.transaction do
          invite.accept || rollback!

          notify_captains(invite.user, invite.team)
        end
      end

      private

      def notify_captains(user, team)
        message = "'#{user.name}' has accepted the invitation to join '#{team.name}'!"

        User.get_revokeable(:edit, team).each do |captain|
          captain.notify!(message, user_path(user))
        end
      end
    end
  end
end
