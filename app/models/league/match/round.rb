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

      validate :can_draw

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

      private

      def set_defaults
        self.home_team_score = 0 unless home_team_score.present?
        self.away_team_score = 0 unless away_team_score.present?
      end

      def can_draw
        return unless match.present? && match.home_team

        if match_can_draw? && !league.allow_round_draws? && home_team_score == away_team_score
          errors.add(:away_team_score, 'cannot be tied')
        end
      end

      def match_can_draw?
        !match.pending? && match.no_forfeit?
      end
    end
  end
end
