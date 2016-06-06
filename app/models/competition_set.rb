class CompetitionSet < ActiveRecord::Base
  belongs_to :match, class_name: 'CompetitionMatch', foreign_key: 'competition_match_id'
  belongs_to :map

  validates :match,           presence: true
  validates :home_team_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :away_team_score, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :can_draw

  delegate :division, to: :match, allow_nil: true
  delegate :competition, to: :match, allow_nil: true

  after_initialize :set_defaults, unless: :persisted?

  scope :home_team_wins, lambda {
    where(arel_table[:home_team_score].gt(arel_table[:away_team_score]))
  }

  scope :away_team_wins, lambda {
    where(arel_table[:away_team_score].gt(arel_table[:home_team_score]))
  }

  scope :draws, -> { where(arel_table[:away_team_score].eq(arel_table[:home_team_score])) }

  private

  def set_defaults
    self.home_team_score = 0 unless home_team_score.present?
    self.away_team_score = 0 unless away_team_score.present?
  end

  def can_draw
    return unless match.present?

    if !match.pending? && !competition.allow_set_draws? && home_team_score == away_team_score
      errors.add(:away_team_score, "cannot be tied")
    end
  end
end
