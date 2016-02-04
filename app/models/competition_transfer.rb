class CompetitionTransfer < ActiveRecord::Base
  belongs_to :competition_roster
  belongs_to :user
end
