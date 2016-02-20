class Division < ActiveRecord::Base
  belongs_to :competition
  has_many :rosters, class_name: 'CompetitionRoster'
  has_many :matches, through: :rosters, class_name: 'CompetitionMatch'

  validates :competition, presence: true
  validates :name, presence: true, length: { in: 1..64 }
  validates :description, presence: true
  validates :min_teams, presence: true, numericality: { greater_than: 1 }
  validates :max_teams, presence: true, numericality: { greater_than: 1 }
  validate :validate_teams_range
  validates :min_players, presence: true, numericality: { greater_than: 0 }
  validates :max_players, presence: true, numericality: { greater_than: 0 }
  validate :validate_players_range

  after_initialize :set_defaults

  alias_attribute :to_s, :name

  private

  def validate_teams_range
    if min_teams.present? && max_teams.present? &&
       min_teams > max_teams
      errors.add(:min_teams, "can't be greater than maximum teams")
    end
  end

  def validate_players_range
    if min_players.present? && max_players.present? &&
       min_players > max_players
      errors.add(:min_players, "can't be greater than maximum players")
    end
  end

  def set_defaults
    self.min_teams = 4    if min_teams.nil?
    self.max_teams = 16   if max_teams.nil?
    self.min_players = 6  if min_players.nil?
    self.max_players = 16 if max_players.nil?
  end
end
