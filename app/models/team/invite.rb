class Team
  class Invite < ApplicationRecord
    include Rails.application.routes.url_helpers

    belongs_to :user
    belongs_to :team

    validates :user, uniqueness: { scope: :team }
    validate :user_not_in_team

    def accept
      transaction do
        team.add_player!(user)

        destroy || fail(ActiveRecord::Rollback)
      end
    end

    def decline
      destroy
    end

    private

    def user_not_in_team
      if team.present? && user.present?
        errors.add(:user, 'already in team') if team.on_roster?(user)
      end
    end
  end
end
