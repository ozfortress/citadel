module Teams
  module CreationService
    include BaseService

    def call(user, params)
      team = Team.new(params)

      team.transaction do
        team.save || rollback!
        team.add_player!(user)
        user.grant(:edit, team)
      end

      team
    end
  end
end
