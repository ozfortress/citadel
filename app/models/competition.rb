class Competition < ActiveRecord::Base
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

  after_initialize :set_defaults

  def public?
    !private?
  end

  def roster_transfer(user)
    transfers.where(user_id: user.id)
             .order(created_at: :desc)
             .limit(1)
             .where(is_joining: true)
  end

  alias_attribute :to_s, :name

  private

  def set_defaults
    self.private = true if private.nil?
    self.signuppable = false if signuppable.nil?
    self.roster_locked = false if signuppable.nil?
  end
end
