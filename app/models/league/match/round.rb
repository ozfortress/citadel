require 'validators/reduce_errors_validator'

class League
  class Match
    class Round < ApplicationRecord
      default_scope { order(:id) }

      belongs_to :match, class_name: 'Match'
      belongs_to :map

      belongs_to :winner, class_name: 'League::Roster', optional: true
      belongs_to :loser,  class_name: 'League::Roster', optional: true

      delegate :division, to: :match, allow_nil: true
      delegate :league,   to: :match, allow_nil: true

      validates :home_team_score, presence: true, numericality: { greater_than_or_equal_to: 0 },
                                  reduce_errors: true
      validates :away_team_score, presence: true, numericality: { greater_than_or_equal_to: 0 },
                                  reduce_errors: true
      validates :has_outcome, inclusion: { in: [true, false] }

      validate :validate_scores
      validate :validate_winner

      scope :with_outcome, -> { where(has_outcome: true) }
      scope :winner, ->(winner) { with_outcome.where(winner: winner) }
      scope :loser, ->(loser) { with_outcome.where(loser: loser) }
      scope :drawn, -> { with_outcome.where(winner: nil) }

      after_initialize :set_defaults, unless: :persisted?

      def draw?
        home_team_score == away_team_score
      end

      def update_cache!
        update_team_cache!
        update_outcome_cache!
      end

      def update_team_cache!
        if home_team_score > away_team_score
          self.winner_id = match.home_team_id
          self.loser_id  = match.away_team_id
        elsif away_team_score > home_team_score
          self.winner_id = match.away_team_id
          self.loser_id  = match.home_team_id
        else
          self.winner_id = nil
          self.loser_id  = nil
        end
      end

      def update_outcome_cache!
        self.has_outcome = calculate_has_outcome
      end

      private

      def calculate_has_outcome
        if !match.pending? && match.no_forfeit?
          if match.has_winner?
            calculate_winnable_match_has_outcome
          else
            true
          end
        else
          false
        end
      end

      def calculate_winnable_match_has_outcome
        wins = Hash.new 0
        match.rounds.each do |round|
          break if round == self

          wins[round.winner_id] += 1
        end

        wins_needed = match.rounds.size / 2.0
        !wins.values.any? { |count| count >= wins_needed }
      end

      def set_defaults
        self.home_team_score = 0 unless home_team_score.present?
        self.away_team_score = 0 unless away_team_score.present?
      end

      def validate_scores
        return unless match.present? && match.home_team

        update_outcome_cache!
        if has_outcome? && !league.allow_round_draws? && draw?
          errors.add(:away_team_score, 'cannot be tied')
        end
      end

      def validate_winner
        return unless match.present? && match.home_team

        update_team_cache!
      end
    end
  end
end
