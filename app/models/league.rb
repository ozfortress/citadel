require 'search'

class League < ApplicationRecord
  belongs_to :format

  has_many :divisions, inverse_of: :league, dependent: :destroy
  accepts_nested_attributes_for :divisions, allow_destroy: true
  has_many :tiebreakers, inverse_of: :league, dependent: :destroy
  accepts_nested_attributes_for :tiebreakers, allow_destroy: true
  has_many :pooled_maps, inverse_of: :league, dependent: :destroy
  accepts_nested_attributes_for :pooled_maps, allow_destroy: true

  has_many :rosters,           through: :divisions, class_name: 'Roster',
                               counter_cache: :rosters_count
  has_many :transfers,         through: :rosters,   class_name: 'Roster::Transfer'
  has_many :players,           through: :rosters,   class_name: 'Roster::Player'
  has_many :transfer_requests, through: :rosters,   class_name: 'Roster::TransferRequest'
  has_many :matches,           through: :divisions, class_name: 'Match'
  has_many :titles,                                 class_name: 'User::Title'

  enum status: [:hidden, :running, :completed]
  validates :name,        presence: true, length: { in: 1..64 }
  validates :description, presence: true
  validates :signuppable,                inclusion: { in: [true, false] }
  validates :roster_locked,              inclusion: { in: [true, false] }
  validates :matches_submittable,        inclusion: { in: [true, false] }
  validates :transfers_require_approval, inclusion: { in: [true, false] }
  validates :allow_round_draws,          inclusion: { in: [true, false] }
  validates :allow_disbanding,           inclusion: { in: [true, false] }
  validates :schedule_locked,            inclusion: { in: [true, false] }

  validates :min_players, presence: true, numericality: { greater_than: 0 }
  validates :max_players, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :points_per_round_won,          presence: true, numericality: { only_integer: true }
  validates :points_per_round_drawn,        presence: true, numericality: { only_integer: true }
  validates :points_per_round_lost,         presence: true, numericality: { only_integer: true }
  validates :points_per_match_forfeit_loss, presence: true, numericality: { only_integer: true }
  validates :points_per_match_forfeit_win,  presence: true, numericality: { only_integer: true }

  # Scheduling
  enum schedule: [:manual, :weeklies]
  has_one :weekly_scheduler, inverse_of: :league, class_name: 'League::Schedulers::Weekly',
                             dependent: :destroy
  accepts_nested_attributes_for :weekly_scheduler

  validate :validate_players_range
  validate :validate_has_scheduler

  scope :not_hidden, -> { where.not(status: League.statuses[:hidden]) }

  after_initialize :set_defaults, unless: :persisted?
  before_save :update_query_cache
  after_save :update_roster_match_counters

  alias_attribute :to_s, :name

  def self.search(query)
    return order(:id) if query.blank?

    query = Search.transform_query(query)

    select('leagues.*', "(query_name_cache <-> #{sanitize(query)}) AS similarity")
      .where('(query_name_cache <-> ?) < 0.9', query)
      .order('similarity')
  end

  def entered?(user)
    players.where(user: user).exists?
  end

  def roster_for(user)
    player = players.find_by(user: user)

    player.roster if player
  end

  def ordered_rosters_by_division
    return divisions.map { |div| [div, []] } if rosters.approved.empty?
    rosters.includes(:division).order(:division_id).approved.ordered(self).group_by(&:division)
  end

  def valid_roster_size?(size)
    min_players <= size && (size <= max_players || max_players.zero?)
  end

  def map_pool
    if pooled_maps.empty?
      Map.all
    else
      Map.where(id: pooled_maps.select(:map_id))
    end
  end

  def scheduler
    case schedule
    when 'manual'
      nil
    when 'weeklies'
      weekly_scheduler
    else
      throw
    end
  end

  def point_multipliers
    [points_per_round_won, points_per_round_drawn, points_per_round_lost,
     points_per_match_forfeit_win, points_per_match_forfeit_loss]
  end

  def reset_query_cache!
    update_query_cache
    save!
  end

  private

  def update_query_cache
    self.query_name_cache = Search.transform_query(name)
  end

  def update_roster_match_counters
    rosters.approved.find_each(&:update_match_counters!)
  end

  def validate_players_range
    if min_players.present? && max_players.present? &&
       min_players > max_players && max_players != 0
      errors.add(:min_players, "can't be greater than maximum players")
    end
  end

  def validate_has_scheduler
    errors.add(:schedule, 'missing scheduler') unless schedule == 'manual' || scheduler.present?
  end

  def set_defaults
    self.status ||= :private
    self.signuppable ||= true
    self.roster_locked = false unless roster_locked.present?

    self.min_players ||= 6
    self.max_players ||= 16

    self.schedule ||= :manual
  end
end
