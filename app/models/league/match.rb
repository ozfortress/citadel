class League
  class Match < ApplicationRecord
    belongs_to :home_team, class_name: 'Roster'
    belongs_to :away_team, class_name: 'Roster', optional: true

    has_many :rounds, inverse_of: :match, class_name: 'Match::Round', dependent: :destroy
    accepts_nested_attributes_for :rounds, allow_destroy: true

    has_many :pick_bans, inverse_of: :match, class_name: 'Match::PickBan', dependent: :destroy
    accepts_nested_attributes_for :pick_bans, allow_destroy: true

    has_many :comms, class_name: 'Match::Comm', dependent: :destroy

    validates :rounds, associated: true # Make *really* sure all rounds are valid

    enum status: [:pending, :submitted_by_home_team, :submitted_by_away_team, :confirmed]
    validates :status, presence: true

    enum forfeit_by: [:no_forfeit, :home_team_forfeit, :away_team_forfeit,
                      :mutual_forfeit, :technical_forfeit]
    validates :forfeit_by, presence: true
    validates :round, allow_nil: :true, numericality: { greater_than_or_equal_to: 0 }
    validates :notice, presence: true, allow_blank: true

    validate :home_and_away_team_are_different
    validate :home_and_away_team_are_in_the_same_division
    validate :teams_are_approved
    validate :rosters_not_disbanded, on: :create

    delegate :division, to: :home_team, allow_nil: true
    delegate :league,   to: :division,  allow_nil: true

    after_initialize :set_defaults, unless: :persisted?

    before_validation do
      self.status = :confirmed unless forfeit_by == 'no_forfeit'
      self.rounds = [] if bye?
    end

    scope :bye, -> { where(away_team: nil) }
    scope :not_bye, -> { where.not(away_team: nil) }
    scope :not_forfeited, -> { confirmed.no_forfeit }
    scope :home_team_forfeited, -> { confirmed.home_team_forfeit }
    scope :away_team_forfeited, -> { confirmed.away_team_forfeit }
    scope :mutually_forfeited, -> { confirmed.mutual_forfeit }
    scope :technically_forfeited, -> { confirmed.technical_forfeit }

    after_save :update_roster_match_counters!
    after_destroy :update_roster_match_counters!

    def confirm_scores(confirm)
      update(status: confirm ? :confirmed : :pending)
    end

    def forfeit(is_home_team)
      update(forfeit_by: (is_home_team ? :home_team_forfeit : :away_team_forfeit))
    end

    def reset_results
      self.status = :pending
      self.forfeit_by = :no_forfeit
    end

    def bye?
      !away_team_id
    end

    def picking_completed?
      pick_bans.pending.empty?
    end

    def map_pool
      league.map_pool.where.not(id: pick_bans.completed.select(:map_id))
    end

    private

    def update_roster_match_counters!
      home_team.update_match_counters!
      away_team.update_match_counters! if away_team
    end

    def home_and_away_team_are_different
      return unless home_team.present? && away_team.present?

      errors.add(:away_team, 'must not be the same as the home team') if away_team == home_team
    end

    def home_and_away_team_are_in_the_same_division
      return unless home_team.present? && away_team.present?

      unless away_team.division == home_team.division
        errors.add(:away_team, 'must be in the same division as the home team')
      end
    end

    def teams_are_approved
      errors.add(:home_team, 'must be approved') if home_team.present? && !home_team.approved?
      errors.add(:away_team, 'must be approved') if away_team.present? && !away_team.approved?
    end

    def rosters_not_disbanded
      errors.add(:home_team, 'is disbanded and cannot play') if home_team.present? &&
                                                                home_team.disbanded?
      errors.add(:away_team, 'is disbanded and cannot play') if away_team.present? &&
                                                                away_team.disbanded?
    end

    def set_defaults
      self.status = (bye? && home_team) ? :confirmed : :pending unless status.present?
    end
  end
end
