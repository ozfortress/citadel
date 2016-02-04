class CompetitionTransfer < ActiveRecord::Base
  belongs_to :user
  belongs_to :roster, foreign_key: 'competition_roster_id'

  validates :user, presence: true
  validates :roster, presence: true
  validates :is_joining, presence: true, inclusion: { in: [true, false] }
  validates :approved, presence: true, inclusion: { in: [true, false] }
end
