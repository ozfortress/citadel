class CompetitionComm < ActiveRecord::Base
  self.table_name = 'competition_match_comms'

  belongs_to :user
  belongs_to :match, class_name: 'CompetitionMatch', foreign_key: 'competition_match_id'

  validates :user,    presence: true
  validates :match,   presence: true
  validates :content, presence: true
end
