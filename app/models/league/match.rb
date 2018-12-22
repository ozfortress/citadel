class League
  class Match < ApplicationRecord
    include MarkdownRenderCaching

    belongs_to :home_team, class_name: 'Roster'
    belongs_to :away_team, class_name: 'Roster', optional: true

    belongs_to :winner, class_name: 'Roster', optional: true
    belongs_to :loser,  class_name: 'Roster', optional: true

    has_many :rounds, inverse_of: :match, class_name: 'Match::Round', dependent: :destroy
    accepts_nested_attributes_for :rounds, allow_destroy: true

    has_many :pick_bans, inverse_of: :match, class_name: 'Match::PickBan', dependent: :destroy
    accepts_nested_attributes_for :pick_bans, allow_destroy: true

    has_many :comms, class_name: 'Match::Comm', dependent: :destroy

    delegate :division, :league, to: :home_team, allow_nil: true

    validates :rounds, associated: true # Make *really* sure all rounds are valid

    enum status: [:pending, :submitted_by_home_team, :submitted_by_away_team, :confirmed]
    validates :status, presence: true

    validates :has_winner,        inclusion: { in: [true, false] }
    validates :allow_round_draws, inclusion: { in: [true, false] }

    enum forfeit_by: [:no_forfeit, :home_team_forfeit, :away_team_forfeit, :mutual_forfeit, :technical_forfeit]
    validates :forfeit_by, presence: true
    validates :round_name, presence: true, allow_blank: true
    validates :round_number, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :notice, presence: true, allow_blank: true
    caches_markdown_render_for :notice, escaped: false

    validate :validate_home_and_away_team_are_different
    validate :validate_home_and_away_team_are_in_the_same_division
    validate :validate_teams_are_approved
    validate :validate_rosters_not_disbanded, on: :create
    validate :validate_winner
    validate :validate_draws_not_allowed_when_winnable

    scope :ordered, -> { order(round_number: :desc, created_at: :asc) }
    scope :bye, -> { where(away_team: nil) }
    scope :not_bye, -> { where.not(away_team: nil) }
    scope :round, ->(round) { where(round_number: round) }
    scope :winnable, -> { where(has_winner: true) }

    scope :for_roster, ->(roster) { where(home_team: roster).or(where(away_team: roster)) }

    scope :winner, ->(winner) { no_forfeit.where(winner: winner) }
    scope :drawn, -> { confirmed.winnable.no_forfeit.where(winner: nil) }
    scope :loser, ->(loser) { no_forfeit.where(loser: loser) }
    scope :single_forfeit, -> { home_team_forfeit.or(away_team_forfeit) }
    scope :forfeit_winner, ->(winner) { single_forfeit.where(winner: winner) }
    scope :forfeit_drawn, -> { technical_forfeit }
    scope :forfeit_loser, ->(loser) { single_forfeit.where(loser: loser).or(mutual_forfeit) }

    after_initialize :set_defaults, unless: :persisted?

    before_validation :update_status
    before_validation :update_round_outcomes
    before_validation :update_pick_bans_order_numbers
    before_save :update_cache

    after_create :update_roster_match_counters!, if: :confirmed?
    after_update :update_roster_match_counters!
    after_destroy :update_roster_match_counters!

    def confirm_scores(confirm)
      update(status: confirm ? :confirmed : :pending)
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
      league.map_pool.where.not(id: pick_bans.completed.select(:map_id).where.not(map_id: nil))
    end

    def update_roster_match_counters!
      home_team.update_match_counters!
      away_team&.update_match_counters!
    end

    def reset_cache!
      update_cache
      save!
    end

    def forfeit!(roster)
      # Don't override mutual or technical forfeits
      if no_forfeit?
        if home_team_id == roster.id
          update!(forfeit_by: :home_team_forfeit)
        else
          update!(forfeit_by: :away_team_forfeit)
        end
      elsif roster.id == winner_id
        update!(forfeit_by: :mutual_forfeit)
      end
    end

    private

    def update_cache
      update_team_cache
      update_score_cache
    end

    def update_team_cache
      if bye?
        self.winner_id = home_team_id
        self.loser_id  = nil
      elsif !no_forfeit?
        update_forfeit_team_cache
      elsif !pending? && has_winner?
        update_outcome_team_cache
      else
        clear_team_cache!
      end
    end

    def update_forfeit_team_cache
      if home_team_forfeit?
        self.winner_id = away_team_id
        self.loser_id  = home_team_id
      elsif away_team_forfeit?
        self.winner_id = home_team_id
        self.loser_id  = away_team_id
      else
        clear_team_cache!
      end
    end

    def update_outcome_team_cache
      wins = Hash.new 0
      rounds.select(&:has_outcome).each { |round| wins[round.calculate_winner_id] += 1 }

      wins_needed = rounds.size / 2.0
      self.winner_id, = wins.find { |_, count| count >= wins_needed }
      self.loser_id = winner_id == home_team_id ? away_team_id : home_team_id if winner_id
    end

    def clear_team_cache!
      self.winner_id = nil
      self.loser_id  = nil
    end

    def update_score_cache
      if !bye? && confirmed? && no_forfeit?
        self.total_home_team_score = rounds.map(&:home_team_score).sum
        self.total_away_team_score = rounds.map(&:away_team_score).sum
        self.total_score_difference = rounds.map(&:score_difference).sum
      else
        self.total_home_team_score = 0
        self.total_away_team_score = 0
        self.total_score_difference = 0
      end
    end

    def update_status
      self.status = :confirmed unless no_forfeit?

      if bye?
        self.status = :confirmed
        self.forfeit_by = :no_forfeit

        rounds.clear
      end
    end

    def update_round_outcomes
      # No rounds count for pending or forfeits
      return rounds.each { |round| round.has_outcome = false } if pending? || !no_forfeit?

      # All rounds count if there isn't a winner
      return rounds.each { |round| round.has_outcome = true } unless has_winner?

      update_winnable_match_round_outcomes
    end

    def update_pick_bans_order_numbers
      pick_bans.each_with_index do |pick_ban, index|
        pick_ban.order_number = index
      end
    end

    def update_winnable_match_round_outcomes
      counts = Hash.new 0
      outcome_index = rounds.find_index do |round|
        winner = round.calculate_winner_id
        next false unless winner

        counts[winner] += 1
        counts.values.max >= rounds.length / 2.0
      end

      rounds.each.with_index { |round, index| round.has_outcome = outcome_index.nil? || index <= outcome_index }
    end

    def validate_home_and_away_team_are_different
      return unless home_team.present? && away_team.present?

      errors.add(:away_team, 'must not be the same as the home team') if away_team == home_team
    end

    def validate_home_and_away_team_are_in_the_same_division
      return unless home_team.present? && away_team.present?

      unless away_team.division == home_team.division
        errors.add(:away_team, 'Must be in the same division as the home team')
      end
    end

    def validate_teams_are_approved
      errors.add(:home_team, 'Must be approved') if home_team.present? && !home_team.approved?
      errors.add(:away_team, 'Must be approved') if away_team.present? && !away_team.approved?
    end

    def validate_rosters_not_disbanded
      errors.add(:home_team, 'Is disbanded and cannot play') if home_team.present? && home_team.disbanded?
      errors.add(:away_team, 'Is disbanded and cannot play') if away_team.present? && away_team.disbanded?
    end

    def validate_winner
      return if home_team.blank? || away_team.blank? || pending? || !has_winner?

      update_team_cache

      if no_forfeit?
        validate_no_forfeit_winner
      else
        validate_forfeit_winner
      end
    end

    def validate_no_forfeit_winner
      errors.add(:base, "Scores aren't valid, there must be a winner") if winner_id.nil?
    end

    def validate_forfeit_winner
      errors.add(:forfeit_by, "Technical forfeits aren't possible for matches with winners") if technical_forfeit?
    end

    def validate_draws_not_allowed_when_winnable
      if has_winner && allow_round_draws
        errors.add(:allow_round_draws, "Match rounds can't draw when match has a winner")
      end
    end

    def set_defaults
      self.status = (bye? && home_team ? :confirmed : :pending) if status.blank?
    end
  end
end
