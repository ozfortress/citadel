class League
  class Roster
    class Player < ApplicationRecord
      belongs_to :roster
      belongs_to :user

      delegate :league, :division, to: :roster

      validate :unique_within_league

      after_create do
        roster.transfers.create(user: user, is_joining: true)
      end

      after_destroy do
        roster.transfers.create(user: user, is_joining: false)
      end

      private

      def unique_within_league
        return unless user.present? && roster.present?

        if league.players.where(user: user).where.not(id: id).exists?
          errors.add(:user_id, 'can only be in one roster per league')
        end
      end
    end
  end
end
