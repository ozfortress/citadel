class League
  class Roster
    class Player < ApplicationRecord
      belongs_to :roster
      belongs_to :user

      delegate :league, :division, to: :roster

      include ::Validations::UserUniqueWithinLeague
      validate :validate_user_unique_within_league

      after_create do
        roster.transfers.create(user: user, is_joining: true)
      end

      after_destroy do
        roster.transfers.create(user: user, is_joining: false)
      end
    end
  end
end
