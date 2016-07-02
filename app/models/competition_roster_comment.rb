class CompetitionRosterComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :roster, class_name: 'CompetitionRoster', foreign_key: 'competition_roster_id'

  validates :user,    presence: true
  validates :roster,  presence: true
  validates :content, presence: true
end
