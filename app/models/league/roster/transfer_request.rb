class League
  class Roster
    class TransferRequest < ApplicationRecord
      belongs_to :roster
      belongs_to :user

      delegate :league, :division, to: :roster

      validates :is_joining, inclusion: { in: [true, false] }
      enum status: [:pending, :approved, :denied]

      validate :unique_within_league,                         if: :pending?
      validate :on_team,                                      if: :pending?
      validate :on_roster,                                    if: :pending?
      validate :active_roster,                                if: :pending?
      validate :league_permissions,                           if: :pending?
      validate :within_roster_size_limits,                    if: :pending?
      validate :within_roster_size_limits_for_leaving_roster, if: :pending?

      def approve
        transaction do
          validate || raise(ActiveRecord::Rollback)

          propagate_players!

          if persisted?
            update(status: 'approved') || raise(ActiveRecord::Rollback)
          else
            self.status = :approved
          end
        end

        !pending?
      end

      def deny
        update(status: 'denied')
      end

      def leaving_roster
        @leaving_roster ||= league.roster_for(user)
      end

      private

      def propagate_players!
        if is_joining?
          leaving_roster.remove_player!(user) if leaving_roster
          roster.add_player!(user)
        else
          roster.remove_player!(user)
        end
      end

      def on_team
        return unless user.present? && roster.present? && is_joining?

        unless roster.team.on_roster?(user)
          errors.add(:user_id, 'must be on the team to get transferred to the roster')
        end
      end

      def on_roster
        return unless user.present? && roster.present? && !is_joining?

        errors.add(:user_id, 'is not on the roster') unless roster.on_roster?(user)
      end

      def active_roster
        return unless roster.present? && is_joining?

        errors.add(:base, 'cannot join a disbanded roster') if roster.disbanded?
      end

      def league_permissions
        return unless user.present? && is_joining?

        errors.add(:base, 'user is banned from leagues') unless user.can?(:use, :leagues)
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
        return if roster.disbanded?

        if roster.players.size - 1 < league.min_players
          errors.add(:base, 'would result in too few players on roster')
        end
      end

      def within_roster_size_limits_for_leaving_roster
        return unless user.present? && roster.present? && leaving_roster.present?
        return if leaving_roster.disbanded?

        new_size = leaving_roster.players.size - 1
        unless new_size >= league.min_players
          errors.add(:base, "would cause #{leaving_roster.name} to have too few players")
        end
      end

      def unique_within_league
        return unless user.present? && roster.present? && is_joining?

        if league.transfer_requests.pending.where(user: user).where.not(id: id).exists?
          errors.add(:user_id, 'is already pending a transfer')
        end
      end
    end
  end
end
