class League
  class Match
    class Comm < ActiveRecord::Base
      include Rails.application.routes.url_helpers

      belongs_to :user
      belongs_to :match, class_name: 'Match'

      validates :user,    presence: true
      validates :match,   presence: true
      validates :content, presence: true

      delegate :home_team, to: :match
      delegate :away_team, to: :match
      delegate :league,    to: :match

      after_create do
        message = "'#{user.name}' posted a message on the match: "\
                  "'#{home_team.name}' vs '#{away_team.name}'"

        User.get_revokeable(:edit, home_team.team).each do |captain|
          next if captain == user
          captain.notify!(message, league_match_path(league, match))
        end

        User.get_revokeable(:edit, away_team.team).each do |captain|
          next if captain == user
          captain.notify!(message, league_match_path(league, match))
        end
      end
    end
  end
end
