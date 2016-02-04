class CompetitionRoster < ActiveRecord::Base
  include Roster

  belongs_to :team
  belongs_to :division
  has_many :transfers, class_name: 'CompetitionTransfer'
end
