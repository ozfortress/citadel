module Teams
  module Invites
    module RevocationService
      include BaseService

      def call(invite)
        invite.transaction do
          invite.destroy!

          notify(invite.user, invite.team)
        end
      end

      private

      def notify(user, team)
        captain_message = "An admin has revoked an invite to join '#{team.name}' sent to '#{user.name}'."

        user_message = "An admin has revoked your invite to join '#{team.name}'."

        User.which_can(:edit, team).each do |captain|
          Users::NotificationService.call(captain, message: captain_message, link: user_path(user))
        end

        Users::NotificationService.call(user, message: user_message, link: team_path(team))
      end
    end
  end
end
