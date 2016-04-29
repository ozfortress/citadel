require 'elasticsearch/model'

class Team < ActiveRecord::Base
  include Searchable
  include Roster

  has_many :team_invites
  has_many :transfers, -> { order(created_at: :desc) }
  has_many :competition_rosters

  validates :name, presence: true, uniqueness: true, length: { in: 1..64 }
  validates :description, presence: true, allow_blank: true

  mount_uploader :avatar, AvatarUploader

  alias_attribute :to_s, :name

  def invite(user)
    team_invites.create(user: user)
  end

  def invited?(user)
    team_invites.exists?(user: user)
  end

  def entered?(comp)
    CompetitionRoster.joins(:division)
                     .where(divisions: { competition_id: comp.id })
                     .where(team: self)
                     .exists?
  end
end
