class League
  class Roster
    class TransferRequest < ApplicationRecord
      belongs_to :roster
      belongs_to :user

      delegate :league, :division, to: :roster

      validates :is_joining, inclusion: { in: [true, false] }

      validate :unique_within_league
      validate :on_team,   if: :is_joining?
      validate :on_roster, unless: :is_joining?
      validate :within_roster_size_limits
      validate :within_roster_size_limits_for_leaving_roster, if: :is_joining?

      def approve
        transaction do
          if is_joining?
            leaving_roster.remove_player!(user) if leaving_roster
            roster.add_player!(user)
          else
            roster.remove_player!(user)
          end

          destroy || fail(ActiveRecord::Rollback) if persisted?
        end

        persisted? ? false : self
      end

      def deny
        destroy
      end

      def leaving_roster
        @leaving_roster ||= league.roster_for(user)
      end

      private

      def on_team
        return unless user.present? && roster.present?

        unless roster.team.on_roster?(user)
          errors.add(:user_id, 'must be on the team to get transferred to the roster')
        end
      end

      def on_roster
        return unless user.present? && roster.present?

        errors.add(:user_id, 'is not on the roster') unless roster.on_roster?(user)
      end

      def within_roster_size_limits
        return unless user.present? && roster.present?

        if is_joining?
          within_roster_size_limits_when_joining
        else
          within_roster_size_limits_when_leaving
        end
      end

      def within_roster_size_limits_when_joining
        max_players = league.max_players

        if roster.players.size + 1 > max_players && max_players > 0
          errors.add(:base, 'would result in too many players on roster')
        end
      end

      def within_roster_size_limits_when_leaving
        if roster.players.size - 1 < league.min_players
          errors.add(:base, 'would result in too few players on roster')
        end
      end

      def within_roster_size_limits_for_leaving_roster
        return unless user.present? && roster.present? && leaving_roster.present?

        new_size = leaving_roster.players.size - 1
        unless new_size >= league.min_players
          errors.add(:base, "would cause #{leaving_roster.name} to have too few players")
        end
      end

      def unique_within_league
        return unless user.present? && roster.present?

        if league.transfer_requests.where(user: user).where.not(id: id).exists?
          errors.add(:user_id, 'is already pending a transfer')
        end
      end
    end
  end
end
