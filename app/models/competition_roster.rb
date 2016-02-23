class CompetitionRoster < ActiveRecord::Base
  include Roster

  belongs_to :team
  belongs_to :division
  delegate :competition, to: :division, allow_nil: true
  has_many :transfers, inverse_of: :roster, class_name: 'CompetitionTransfer',
                       dependent: :destroy
  accepts_nested_attributes_for :transfers
  has_many :home_team_matches, class_name: 'CompetitionMatch', foreign_key: 'home_team_id',
                               dependent: :destroy
  has_many :home_team_sets, through: :home_team_matches, source: :sets, class_name: 'CompetitionSet'
  has_many :away_team_matches, class_name: 'CompetitionMatch', foreign_key: 'away_team_id',
                               dependent: :destroy
  has_many :away_team_sets, through: :away_team_matches, source: :sets, class_name: 'CompetitionSet'

  validates :team,        presence: true, uniqueness: { scope: :division_id }
  validates :division,    presence: true
  validates :name,        presence: true, uniqueness: { scope: :division_id },
                          length: { in: 1..64 }
  validates :description, presence: true, allow_blank: true
  validates :approved,    inclusion: { in: [true, false] }
  validate :player_count_limits

  after_initialize :set_defaults

  alias_attribute :to_s, :name

  def matches
    home_team_matches + away_team_matches
  end

  def win_count
    match_outcome_count('>')
  end

  def draw_count
    match_outcome_count('=')
  end

  def loss_count
    match_outcome_count('<')
  end

  def score_s
    "Wins: #{win_count} Draws: #{draw_count} Losses: #{loss_count}"
  end

  private

  def match_outcome_count(comparison)
    (home_team_sets.where(competition_matches: { status: 3 })
                  .where("home_team_score #{comparison} away_team_score")
                  .count +
     away_team_sets.where(competition_matches: { status: 3 })
                   .where("away_team_score #{comparison} home_team_score")
                   .count)
  end

  def set_defaults
    self.approved = false if approved.nil?
  end

  def player_count_limits
    return unless division.present?

    player_count = players.size
    if player_count < division.min_players
      errors.add(:player_ids, "must have at least #{division.min_players} players")
    end

    if player_count > division.max_players
      errors.add(:player_ids, "must have no more than #{division.max_players} players")
    end
  end
end
