require 'validators/reduce_validator'

class League
  class Match
    class Round < ApplicationRecord
      belongs_to :match, class_name: 'Match'
      belongs_to :map

      validates :home_team_score, presence: true, numericality: { greater_than_or_equal_to: 0 },
                                  reduce: true
      validates :away_team_score, presence: true, numericality: { greater_than_or_equal_to: 0 },
                                  reduce: true

      validate :validate_scores

      delegate :division, to: :match, allow_nil: true
      delegate :league,   to: :match, allow_nil: true

      after_initialize :set_defaults, unless: :persisted?

      default_scope { order(:id) }

      scope :home_team_wins, lambda {
        where(arel_table[:home_team_score].gt(arel_table[:away_team_score]))
      }

      scope :away_team_wins, lambda {
        where(arel_table[:away_team_score].gt(arel_table[:home_team_score]))
      }

      scope :draws, -> { where(arel_table[:away_team_score].eq(arel_table[:home_team_score])) }

      before_save do
        unless scores?
          self.home_team_score = 0
          self.away_team_score = 0
        end
      end

      def winning_team
        if home_team_score > away_team_score
          match.home_team
        elsif home_team_score < away_team_score
          match.away_team
        end
      end

      def winning_team_id
        if home_team_score > away_team_score
          match.home_team_id
        elsif home_team_score < away_team_score
          match.away_team_id
        end
      end

      def scores?
        return true unless match.has_winner?

        wins = Hash.new 0
        match.rounds.each do |round|
          break if round == self

          wins[round.winning_team_id] += 1
        end

        # Check if there are any definite winners
        half_rounds = match.rounds.size / 2.0
        !wins.values.any? { |count| count >= half_rounds }
      end

      def draw?
        home_team_score == away_team_score
      end

      private

      def set_defaults
        self.home_team_score = 0 unless home_team_score.present?
        self.away_team_score = 0 unless away_team_score.present?
      end

      def match_has_scores?
        !match.pending? && match.no_forfeit?
      end

      def validate_scores
        return unless match.present? && match.home_team && match_has_scores?

        if scores? && !league.allow_round_draws? && draw?
          errors.add(:away_team_score, 'cannot be tied')
        end
      end
    end
  end
end
