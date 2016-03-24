class Title < ActiveRecord::Base
  belongs_to :user
  belongs_to :competition
  belongs_to :competition_roster

  validates :name, presence: true, length: { in: 1..64 }
end
