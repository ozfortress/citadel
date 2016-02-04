class CompetitionTransfer < ActiveRecord::Base
  belongs_to :user
  belongs_to :roster, foreign_key: 'competition_roster_id'

  validates :user, presence: true
  validates :roster, presence: true
  validates :is_joining, inclusion: { in: [true, false] }
  validates :approved, inclusion: { in: [true, false] }

  after_initialize :set_defaults

  private

  def set_defaults
    self.is_joining = true  if is_joining.nil?
    self.approved   = false if approved.nil?
  end
end
