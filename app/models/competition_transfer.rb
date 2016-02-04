class CompetitionTransfer < ActiveRecord::Base
  belongs_to :user
  belongs_to :roster, foreign_key: 'competition_roster_id'
end
