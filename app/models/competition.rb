require 'elasticsearch/model'

class Competition < ActiveRecord::Base
  include Searchable
  include RosterPlayers

  belongs_to :format
  has_many   :divisions, inverse_of: :competition, dependent: :destroy
  accepts_nested_attributes_for :divisions, allow_destroy: true
  has_many :rosters,   through: :divisions, class_name: 'CompetitionRoster'
  has_many :transfers, through: :rosters,   class_name: 'CompetitionTransfer'
  has_many :matches,   through: :divisions, class_name: 'CompetitionMatch'

  validates :format, presence: true
  validates :name, presence: true, length: { in: 1..64 }
  validates :description, presence: true
  validates :private,                    inclusion: { in: [true, false] }
  validates :signuppable,                inclusion: { in: [true, false] }
  validates :roster_locked,              inclusion: { in: [true, false] }
  validates :matches_submittable,        inclusion: { in: [true, false] }
  validates :transfers_require_approval, inclusion: { in: [true, false] }
  validates :allow_set_draws,            inclusion: { in: [true, false] }
  validates :allow_disbanding,           inclusion: { in: [true, false] }
  validates :min_players, presence: true, numericality: { greater_than: 0 }
  validates :max_players, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :points_per_set_won, presence: true, numericality: { only_integer: true }
  validates :points_per_set_drawn, presence: true, numericality: { only_integer: true }
  validates :points_per_set_lost, presence: true, numericality: { only_integer: true }
  validates :points_per_match_forfeit_loss, presence: true, numericality: { only_integer: true }
  validates :points_per_match_forfeit_win, presence: true, numericality: { only_integer: true }

  validate :validate_players_range

  after_initialize :set_defaults, unless: :persisted?

  alias_attribute :to_s, :name

  def public?
    !private?
  end

  def roster_transfer(user)
    transfers.where(user_id: user.id)
             .order(created_at: :desc)
             .limit(1)
             .where(is_joining: true)
  end

  def as_indexed_json(_ = {})
    as_json(only: [:name, :description])
  end

  def pending_transfers
    transfers.where(approved: false)
  end

  def pending_transfer?(user)
    pending_transfers.where(user_id: user.id).exists?
  end

  def point_multipliers
    [points_per_set_won, points_per_set_drawn, points_per_set_lost, points_per_match_forfeit_win,
     points_per_match_forfeit_loss]
  end

  private

  def validate_players_range
    if min_players.present? && max_players.present? &&
       min_players > max_players && max_players != 0
      errors.add(:min_players, "can't be greater than maximum players")
    end
  end

  def set_defaults
    self.private = true        unless private.present?
    self.signuppable = true    unless signuppable.present?
    self.roster_locked = false unless roster_locked.present?

    self.min_players = 6  unless min_players.present?
    self.max_players = 16 unless max_players.present?
  end
end
