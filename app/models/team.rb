class Team < ActiveRecord::Base
  include Roster

  has_many :team_invites
  has_many :transfers

  validates :name, presence: true, uniqueness: true, length: { in: 1..64 }
  validates :description, presence: true, allow_blank: true

  def invite(user)
    team_invites.create(user: user)
  end

  def invited?(user)
    !team_invites.find_by(user: user).nil?
  end
end
