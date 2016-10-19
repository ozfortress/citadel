module Leagues
  module Rosters
    module CreationService
      include BaseService

      def call(league, team, params)
        params[:team] = team
        roster = league.rosters.new(params)

        roster.transaction do
          roster.save || rollback!

          notify_players(roster, league)
        end

        roster
      end

      private

      def notify_players(roster, league)
        msg  = "You have been entered in #{league.name} with #{roster.name}."
        link = roster_path(roster)

        roster.players.each do |player|
          Users::NotificationService.call(player.user, msg, link)
        end
      end
    end
  end
end
