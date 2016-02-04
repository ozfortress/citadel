class CompetitionRoster < ActiveRecord::Base
  include Roster

  belongs_to :team
  belongs_to :competition
  belongs_to :division
  has_many :transfers, class_name: 'CompetitionTransfer'

  validates :team, presence: true
  validates :competition, presence: true
end
