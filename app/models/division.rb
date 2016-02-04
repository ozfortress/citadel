class Division < ActiveRecord::Base
  belongs_to :competition
  has_many :competition_rosters

  validates :name, presence: true, length: { in: 1..64 }
  validates :description, presence: true
end
