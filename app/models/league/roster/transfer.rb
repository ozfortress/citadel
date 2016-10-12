class League
  class Roster
    class Transfer < ApplicationRecord
      belongs_to :user
      belongs_to :roster, class_name: 'Roster', foreign_key: 'roster_id'
      delegate :team,     to: :roster,   allow_nil: true
      delegate :division, to: :roster,   allow_nil: true
      delegate :league,   to: :division, allow_nil: true

      validates :is_joining, inclusion: { in: [true, false] }
    end
  end
end
