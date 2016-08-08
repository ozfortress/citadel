require 'elasticsearch/model'

class League < ActiveRecord::Base
  include Searchable
  include RosterPlayers

  belongs_to :format

  has_many :divisions, inverse_of: :league, dependent: :destroy
  accepts_nested_attributes_for :divisions, allow_destroy: true
  has_many :tiebreakers, inverse_of: :league, dependent: :destroy,
                         class_name: 'Tiebreaker'
  accepts_nested_attributes_for :tiebreakers, allow_destroy: true

  has_many :rosters,   through: :divisions, class_name: 'Roster', counter_cache: :rosters_count
  has_many :transfers, through: :rosters,   class_name: 'Roster::Transfer'
  has_many :matches,   through: :divisions, class_name: 'Match'
  has_many :titles,    class_name: 'User::Title'

  validates :format, presence: true
  validates :name, presence: true, length: { in: 1..64 }
  validates :description, presence: true
  enum status: [:hidden, :running, :completed]
  validates :signuppable,                inclusion: { in: [true, false] }
  validates :roster_locked,              inclusion: { in: [true, false] }
  validates :matches_submittable,        inclusion: { in: [true, false] }
  validates :transfers_require_approval, inclusion: { in: [true, false] }
  validates :allow_round_draws,          inclusion: { in: [true, false] }
  validates :allow_disbanding,           inclusion: { in: [true, false] }
  validates :min_players, presence: true, numericality: { greater_than: 0 }
  validates :max_players, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :points_per_round_won, presence: true, numericality: { only_integer: true }
  validates :points_per_round_drawn, presence: true, numericality: { only_integer: true }
  validates :points_per_round_lost, presence: true, numericality: { only_integer: true }
  validates :points_per_match_forfeit_loss, presence: true, numericality: { only_integer: true }
  validates :points_per_match_forfeit_win, presence: true, numericality: { only_integer: true }

  validate :validate_players_range

  scope :not_hidden, -> { where.not(status: League.statuses[:hidden]) }

  after_initialize :set_defaults, unless: :persisted?
  after_save :update_roster_match_counters

  alias_attribute :to_s, :name

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
    [points_per_round_won, points_per_round_drawn, points_per_round_lost,
     points_per_match_forfeit_win, points_per_match_forfeit_loss]
  end

  def player_transfers(*args)
    super.where(approved: true)
  end

  private

  def update_roster_match_counters
    rosters.each(&:update_match_counters!)
  end

  def validate_players_range
    if min_players.present? && max_players.present? &&
       min_players > max_players && max_players != 0
      errors.add(:min_players, "can't be greater than maximum players")
    end
  end

  def set_defaults
    self.status = :private     unless status.present?
    self.signuppable = true    unless signuppable.present?
    self.roster_locked = false unless roster_locked.present?

    self.min_players = 6  unless min_players.present?
    self.max_players = 16 unless max_players.present?
  end
end
