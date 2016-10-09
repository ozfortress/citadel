module Teams
  module KickingService
    include BaseService

    def call(user, team)
      team.transaction do
        team.remove_player!(user)
        notify_user(user, team)
      end
    end

    private

    def notify_user(user, team)
      user.notify!("You have been kicked from #{team.name}", team_path(team))
    end
  end
end
