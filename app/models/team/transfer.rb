class Team
  class Transfer < ApplicationRecord
    belongs_to :team
    belongs_to :user

    validates :is_joining, inclusion: { in: [true, false] }
  end
end
