module Teams
  module InvitationService
    include BaseService

    def call(team, user)
      invite = team.invites.new(user:)

      invite.transaction do
        invite.save || rollback!

        Users::NotificationService.call(user, message: invite_message(team), link: team_path(team))
      end

      invite
    end

    private

    def invite_message(team)
      msg = "You have been invited to join the team: #{team.name}."
      msg += " #{expiry_message}" if Team::Invite.expiry
      msg
    end

    def expiry_message
      days = Team::Invite.expiry.in_days.to_i
      "This invite will expire in #{days} #{'day'.pluralize(days)}."
    end
  end
end
