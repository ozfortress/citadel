class Division < ActiveRecord::Base
  belongs_to :competition
  has_many :rosters, class_name: 'CompetitionRoster'
  has_many :matches, through: :rosters, source: :home_team_matches, class_name: 'CompetitionMatch'

  validates :competition, presence: true
  validates :name, presence: true, length: { in: 1..64 }

  alias_attribute :to_s, :name
end
