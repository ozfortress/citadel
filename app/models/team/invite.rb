class Team
  class Invite < ApplicationRecord
    include Rails.application.routes.url_helpers

    belongs_to :user
    belongs_to :team

    validates :user, uniqueness: { scope: :team }

    def accept
      team.add_player!(user: user)
      destroy
    end

    def decline
      destroy
    end
  end
end
