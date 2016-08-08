class User
  class Title < ActiveRecord::Base
    belongs_to :user
    belongs_to :league
    belongs_to :roster, class_name: 'League::Roster'

    validates :user, presence: true
    validates :name, presence: true, length: { in: 1..64 }

    mount_uploader :badge, BadgeUploader

    scope :general, -> { where(league: nil, roster: nil) }
    scope :for_league, -> { where.not(league: nil) }
    scope :for_roster, -> { where.not(roster: nil) }
  end
end
