class Title < ActiveRecord::Base
  belongs_to :user
  belongs_to :competition
  belongs_to :competition_roster

  validates :user, presence: true
  validates :name, presence: true, length: { in: 1..64 }

  mount_uploader :badge, BadgeUploader

  scope :general, -> { where(competition: nil, competition_roster: nil) }
  scope :for_roster, -> { where.not(competition_roster: nil) }
  scope :for_competition, -> { where.not(competition: nil) }
end
