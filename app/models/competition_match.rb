class CompetitionMatch < ActiveRecord::Base
  belongs_to :home_team, class_name: 'CompetitionRoster'
  belongs_to :away_team, class_name: 'CompetitionRoster'
  has_many :sets, inverse_of: :match, class_name: 'CompetitionSet', dependent: :destroy
  accepts_nested_attributes_for :sets
  has_many :comms, class_name: 'CompetitionComm', dependent: :destroy

  validates :home_team, presence: true
  validates :away_team, presence: true

  enum status: [:pending, :submitted_by_home_team, :submitted_by_away_team, :confirmed]
  validates :status, presence: true

  validate :home_and_away_team_are_different
  validate :home_and_away_team_are_in_the_same_division
  validate :teams_are_approved

  delegate :division, to: :home_team, allow_nil: true
  delegate :competition, to: :division, allow_nil: true

  after_initialize :set_defaults

  def to_s
    "#{home_team.name} vs #{away_team.name}"
  end

  private

  def home_and_away_team_are_different
    return unless home_team.present? && away_team.present?

    errors.add(:away_team_id, 'must not be the same as the home team') if away_team == home_team
  end

  def home_and_away_team_are_in_the_same_division
    return unless home_team.present? && away_team.present?

    unless away_team.division == home_team.division
      errors.add(:away_team_id, 'must be in the same division as the home team')
    end
  end

  def teams_are_approved
    errors.add(:home_team_id, 'must be approved') if home_team.present? && !home_team.approved?
    errors.add(:away_team_id, 'must be approved') if away_team.present? && !away_team.approved?
  end

  def set_defaults
    self.status = :pending unless status.present?
  end
end
