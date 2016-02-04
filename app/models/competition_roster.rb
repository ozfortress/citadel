class CompetitionRoster < ActiveRecord::Base
  belongs_to :team
  belongs_to :division
  has_many :competition_transfers
end
