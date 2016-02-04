class CompetitionRoster < ActiveRecord::Base
  include Roster

  belongs_to :team
  belongs_to :division
  has_many :transfers, class_name: 'CompetitionTransfer'

  validates :team, presence: true
  validates :competition, presence: true
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :approved, presence: true, inclusion: { in: [true, false] }
end
