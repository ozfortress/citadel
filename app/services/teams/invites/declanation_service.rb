module Teams
  module Invites
    module DeclanationService
      include BaseService

      def call(invite)
        invite.transaction do
          invite.decline || rollback!

          notify_captains(invite.user, invite.team)
        end
      end

      private

      def notify_captains(user, team)
        message = "'#{user.name}' has declined the invitation to join '#{team.name}'."

        User.which_can(:edit, team).each do |captain|
          Users::NotificationService.call(captain, message: message, link: user_path(user))
        end
      end
    end
  end
end
