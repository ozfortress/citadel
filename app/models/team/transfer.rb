class Team
  class Transfer < ApplicationRecord
    include Rails.application.routes.url_helpers

    belongs_to :team
    belongs_to :user

    validates :is_joining, inclusion: { in: [true, false] }

    after_create do
      unless is_joining?
        User.get_revokeable(:edit, team).each do |captain|
          captain.notify!("'#{user.name}' has left the team '#{team.name}'", user_path(user))
        end
      end
    end
  end
end
