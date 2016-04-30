require 'elasticsearch/model'

class Competition < ActiveRecord::Base
  include Searchable
  include RosterPlayers

  transfers_table_name 'competition_transfers'

  belongs_to :format
  has_many   :divisions, inverse_of: :competition, dependent: :destroy
  accepts_nested_attributes_for :divisions, allow_destroy: true
  has_many :rosters,   through: :divisions, class_name: 'CompetitionRoster'
  has_many :transfers, through: :rosters,   class_name: 'CompetitionTransfer'
  has_many :matches,   through: :divisions, class_name: 'CompetitionMatch'

  validates :format, presence: true
  validates :name, presence: true, length: { in: 1..64 }
  validates :description, presence: true
  validates :private, inclusion: { in: [true, false] }
  validates :signuppable, inclusion: { in: [true, false] }
  validates :roster_locked, inclusion: { in: [true, false] }
  validates :matches_submittable, inclusion: { in: [true, false] }
  validates :min_players, presence: true, numericality: { greater_than: 0 }
  validates :max_players, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :validate_players_range

  after_initialize :set_defaults

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

  private

  def validate_players_range
    if min_players.present? && max_players.present? &&
       min_players > max_players && max_players != 0
      errors.add(:min_players, "can't be greater than maximum players")
    end
  end

  def set_defaults
    self.private = true if private.nil?
    self.signuppable = false if signuppable.nil?
    self.roster_locked = false if signuppable.nil?

    self.min_players = 6  if min_players.nil?
    self.max_players = 16 if max_players.nil?
  end
end
