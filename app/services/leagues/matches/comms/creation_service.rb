module Leagues
  module Matches
    module Comms
      module CreationService
        include BaseService

        def call(user, match, params)
          params[:user] = user
          comm_params = params.merge(match: match)
          comm = League::Match::Comm.new(comm_params)

          comm.transaction do
            comm.save || rollback!
            comm.edits.create!(params)

            notify_captains!(user, match)
          end

          comm
        end

        private

        def notify_captains!(user, match)
          message = "'#{user.name}' posted a message on the match: "\
                    "'#{match.home_team.name}' vs '#{match.away_team.name}'"
          link = match_path(match)

          notify_captains(match.home_team, user, message, link)
          notify_captains(match.away_team, user, message, link)
        end

        def notify_captains(roster, user, message, link)
          User.which_can(:edit, roster.team).each do |captain|
            next if captain == user
            Users::NotificationService.call(captain, message, link)
          end
        end
      end
    end
  end
end
