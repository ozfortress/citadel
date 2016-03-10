class CompetitionTransfer < ActiveRecord::Base
  belongs_to :user
  belongs_to :roster, foreign_key: 'competition_roster_id', class_name: 'CompetitionRoster'
  delegate :division,    to: :roster,   allow_nil: true
  delegate :competition, to: :division, allow_nil: true

  validates :user, presence: true
  validates :roster, presence: true
  validates :is_joining, inclusion: { in: [true, false] }
  validates :approved, inclusion: { in: [true, false] }
  validate :single_player_entry, on: :create

  after_initialize :set_defaults

  private

  def set_defaults
    self.is_joining = true  if is_joining.nil?
    self.approved   = false if approved.nil?
  end

  def single_player_entry
    return unless competition.present?

    transfer = competition.players.find_by(user: user)
    unless transfer.nil?
      errors.add(:user_id, "is already entered in this league with #{transfer.roster}")
    end
  end
end
