class Division < ActiveRecord::Base
  belongs_to :competition
  has_many :competition_rosters

  validates :competition, presence: true
  validates :name, presence: true, length: { in: 1..64 }
  validates :description, presence: true
  validates :min_teams, presence: true, numericality: { greater_than: 1 }
  validates :max_teams, presence: true, numericality: { greater_than: 1 }
  validate :validate_teams_range
  validates :min_players, presence: true, numericality: { greater_than: 0 }
  validates :max_players, presence: true, numericality: { greater_than: 0 }
  validate :validate_players_range

  private

  def validate_teams_range
    if min_teams > max_teams
      errors.add(:min_teams, "can't be greater than maximum teams")
    end
  end

  def validate_players_range
    if min_players > max_players
      errors.add(:min_players, "can't be greater than maximum players")
    end
  end
end
