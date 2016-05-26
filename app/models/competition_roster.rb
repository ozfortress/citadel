class CompetitionRoster < ActiveRecord::Base
  include Roster

  belongs_to :team
  belongs_to :division
  delegate :competition, to: :division, allow_nil: true
  has_many :transfers, -> { order(created_at: :desc) }, inverse_of: :roster,
                                                        class_name: 'CompetitionTransfer',
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
  validate :player_count_minimums
  validate :player_count_maximums

  after_initialize :set_defaults, unless: :persisted?

  alias_attribute :to_s, :name

  def matches
    home_matches = home_team_matches.select(:id).to_sql
    away_matches = away_team_matches.select(:id).to_sql
    CompetitionMatch.where("id IN (#{home_matches}) OR id IN (#{away_matches})")
  end

  def upcoming_matches
    matches.where.not(status: 'confirmed')
  end

  def approved_transfers
    transfers.where(approved: true)
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

  def players_off_roster
    team.players.where.not(user: players.map(&:user_id))
  end

  def users_off_roster
    players_off_roster.map(&:user)
  end

  def player_transfers(tfers = nil, unique_for = 'user_id')
    super.where(approved: true)
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
    self.approved = false unless approved.present?
  end

  def player_count_minimums
    return unless competition.present?

    min_players = competition.min_players
    if players.size < min_players
      errors.add(:player_ids, "must have at least #{min_players} players")
    end
  end

  def player_count_maximums
    return unless competition.present?

    max_players = competition.max_players
    if players.size > max_players && max_players > 0
      errors.add(:player_ids, "must have no more than #{max_players} players")
    end
  end
end
