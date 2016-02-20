class CompetitionSet < ActiveRecord::Base
  belongs_to :match, class_name: 'CompetitionMatch', foreign_key: 'competition_match_id'
  belongs_to :map

  validates :match,           presence: true
  validates :home_team_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :away_team_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
