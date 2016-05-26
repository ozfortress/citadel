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
  validate :on_team, on: :create
  validate :within_roster_size, on: :create

  after_initialize :set_defaults, unless: :persisted?

  private

  def set_defaults
    self.is_joining = true  if is_joining.nil?
    self.approved   = false if approved.nil?

    if competition.present? && (!competition.transfers_require_approval? ||
                                competition.signuppable?)
      self.approved = true
    end
  end

  def single_player_entry
    return unless competition.present? && is_joining

    transfer = competition.players.where(user: user)
    if transfer.exists?
      errors.add(:user_id, "is already entered in this league with #{transfer.first.roster}")
    end
  end

  def on_team
    return unless user.present? && roster.present?

    if is_joining?
      on_team_for_joining
    else
      on_team_for_leaving
    end
  end

  def on_team_for_joining
    unless roster.team.on_roster?(user) && !roster.on_roster?(user)
      errors.add(:user_id, 'must be on the team to get transferred to the roster')
    end
  end

  def on_team_for_leaving
    unless roster.on_roster?(user)
      errors.add(:user_id, 'must be on the roster to get transferred out')
    end
  end

  def within_roster_size
    return unless roster.present? && roster.persisted? && competition.present?

    if is_joining?
      within_roster_size_for_joining
    else
      within_roster_size_for_leaving
    end
  end

  def within_roster_size_for_joining
    if roster.players.size == competition.max_players
      errors.add(:user_id, 'transferring in would make the roster too large')
    end
  end

  def within_roster_size_for_leaving
    if roster.players.size == competition.min_players
      errors.add(:user_id, 'transferring out would make the roster too small')
    end
  end
end
