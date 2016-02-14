class CompetitionMatch < ActiveRecord::Base
  belongs_to :division
  delegate :competition, to: :division, allow_nil: true
  belongs_to :home_team, class_name: 'CompetitionRoster'
  belongs_to :away_team, class_name: 'CompetitionRoster'
  has_many :sets, inverse_of: :match, class_name: 'CompetitionSet'
  accepts_nested_attributes_for :sets

  validates :division,  presence: true
  validates :home_team, presence: true
  validates :away_team, presence: true

  enum status: [:pending, :submitted, :confirmed]
  validates :status, presence: true

  def to_s
    "#{home_team.name} vs #{away_team.name}"
  end
end
