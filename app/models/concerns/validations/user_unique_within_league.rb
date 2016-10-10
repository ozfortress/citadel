module Validations
  module UserUniqueWithinLeague
    def validate_user_unique_within_league
      return unless user.present? && roster.present?

      if league.players.where(user: user).where.not(id: id).exists?
        errors.add(:user_id, 'can only be in one roster per league')
      end
    end
  end
end
