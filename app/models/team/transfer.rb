class Team
  class Transfer < ApplicationRecord
    include Rails.application.routes.url_helpers

    belongs_to :team
    belongs_to :user

    validates :is_joining, inclusion: { in: [true, false] }
  end
end
