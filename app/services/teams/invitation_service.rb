module Teams
  module InvitationService
    include BaseService

    def call(team, user)
      invite = team.invites.new(user: user)

      invite.transaction do
        invite.save || rollback!

        user.notify!("You have been invited to join the team: #{team.name}.", team_path(user))
      end

      invite
    end
  end
end
