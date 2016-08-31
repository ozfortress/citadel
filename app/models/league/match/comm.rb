class League
  class Match
    class Comm < ApplicationRecord
      include Rails.application.routes.url_helpers

      belongs_to :user
      belongs_to :match, class_name: 'Match'

      validates :content, presence: true

      delegate :home_team, to: :match
      delegate :away_team, to: :match
      delegate :league,    to: :match

      after_create do
        message = "'#{user.name}' posted a message on the match: "\
                  "'#{home_team.name}' vs '#{away_team.name}'"
        link = league_match_path(league, match)

        notify_captains(home_team, message, link)
        notify_captains(away_team, message, link)
      end

      private

      def notify_captains(roster, message, link)
        User.get_revokeable(:edit, roster.team).each do |captain|
          next if captain == user
          captain.notify!(message, link)
        end
      end
    end
  end
end
