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

  private

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
