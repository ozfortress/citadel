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
      msg = "You have been kicked from #{team.name}"
      Users::NotificationService.call(user, msg, team_path(team))
    end
  end
end
