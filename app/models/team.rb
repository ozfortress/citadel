class Team < ActiveRecord::Base
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

  def add_player(user)
    transfers.create!(user: user, is_joining?: true)
  end

  def remove_player(user)
    transfers.create!(user: user, is_joining?: false)
  end

  def on_roster?(user)
    # TODO: Massive optimisations
    roster.include? user
  end

  def roster
    # TODO: Maybe turn this into a big query?
    players = Set.new
    transfers.each do |transfer|
      if transfer.is_joining?
        players << transfer.user
      else
        players.delete(transfer.user)
      end
    end

    players.to_a.sort! { |a, b| a.name.downcase <=> b.name.downcase }
  end
end
