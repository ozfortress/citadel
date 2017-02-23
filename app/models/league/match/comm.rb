class League
  class Match
    class Comm < ApplicationRecord
      include Rails.application.routes.url_helpers

      belongs_to :user
      belongs_to :match, class_name: 'Match'

      has_many :edits, class_name: 'CommEdit', dependent: :delete_all

      validates :content, presence: true, length: { in: 2..1_000 }

      delegate :home_team, to: :match
      delegate :away_team, to: :match
      delegate :league,    to: :match
    end
  end
end
