require 'validators/reduce_errors_validator'

class League
  class Match
    class Round < ApplicationRecord
      default_scope { order(:id) }

      belongs_to :match, class_name: 'Match'
      belongs_to :map

      belongs_to :winner, class_name: 'League::Roster', optional: true
      belongs_to :loser,  class_name: 'League::Roster', optional: true

      delegate :division, :league, :home_team, :home_team_id, :away_team, :away_team_id, to: :match, allow_nil: true

      validates :home_team_score, presence: true, numericality: { greater_than_or_equal_to: 0 }, reduce_errors: true
      validates :away_team_score, presence: true, numericality: { greater_than_or_equal_to: 0 }, reduce_errors: true
      validates :has_outcome, inclusion: { in: [true, false] }

      validate :validate_scores

      scope :with_outcome, -> { where(has_outcome: true) }
      scope :winner, ->(winner) { with_outcome.where(winner: winner) }
      scope :loser, ->(loser) { with_outcome.where(loser: loser) }
      scope :drawn, -> { with_outcome.where(winner: nil) }

      before_save :update_cache

      def draw?
        home_team_score == away_team_score
      end

      def reset_cache!
        update_cache
        save!
      end

      def calculate_winner_id
        if home_team_score > away_team_score
          match.home_team_id
        elsif away_team_score > home_team_score
          match.away_team_id
        end
      end

      private

      def update_cache
        self.score_difference = home_team_score - away_team_score

        update_wl_cache
      end

      def update_wl_cache
        if home_team_score > away_team_score && has_outcome
          self.winner_id = match.home_team_id
          self.loser_id  = match.away_team_id
        elsif away_team_score > home_team_score && has_outcome
          self.winner_id = match.away_team_id
          self.loser_id  = match.home_team_id
        else
          self.winner_id = nil
          self.loser_id  = nil
        end
      end

      def validate_scores
        return if match.blank?

        errors.add(:away_team_score, 'Cannot be tied') if has_outcome? && !match.allow_round_draws? && draw?
      end
    end
  end
end
