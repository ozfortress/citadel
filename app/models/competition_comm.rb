class CompetitionComm < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  self.table_name = 'competition_match_comms'

  belongs_to :user
  belongs_to :match, class_name: 'CompetitionMatch', foreign_key: 'competition_match_id'

  validates :user,    presence: true
  validates :match,   presence: true
  validates :content, presence: true

  delegate :home_team, to: :match
  delegate :away_team, to: :match
  delegate :competition, to: :match

  after_create do
    message = "'#{user.name}' posted a message on the match: "\
              "'#{home_team.name}' vs '#{away_team.name}'"

    User.get_revokeable(:edit, home_team.team).each do |captain|
      next if captain == user
      captain.notify!(message, league_match_path(competition, match))
    end

    User.get_revokeable(:edit, away_team.team).each do |captain|
      next if captain == user
      captain.notify!(message, league_match_path(competition, match))
    end
  end
end
