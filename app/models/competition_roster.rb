class CompetitionRoster < ActiveRecord::Base
  include Roster

  belongs_to :team
  belongs_to :division
  delegate :competition, to: :division, allow_nil: true
  has_many :transfers, inverse_of: :roster, class_name: 'CompetitionTransfer'
  accepts_nested_attributes_for :transfers

  validates :team,        presence: true, uniqueness: { scope: :division_id }
  validates :division,    presence: true
  validates :name,        presence: true, uniqueness: { scope: :division_id },
                          length: { in: 1..64 }
  validates :description, presence: true, allow_blank: true
  validates :points,      presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :approved,    inclusion: { in: [true, false] }
  validate :player_count_limits

  after_initialize :set_defaults

  private

  def set_defaults
    self.points   = 0     if points.nil?
    self.approved = false if approved.nil?
  end

  def player_count_limits
    return unless division.present?

    player_count = players.size
    if player_count < division.min_players
      errors.add(:player_ids, "must have at least #{division.min_players} players")
    end

    if player_count > division.max_players
      errors.add(:player_ids, "must have no more than #{division.max_players} players")
    end
  end
end
