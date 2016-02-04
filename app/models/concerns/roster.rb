module Roster
  extend ActiveSupport::Concern

  def add_player(user)
    transfers.create!(user: user, is_joining?: true)
  end

  def remove_player(user)
    transfers.create!(user: user, is_joining?: false)
  end

  def on_roster?(user)
    # TODO: Massive optimisation
    players.include? user
  end

  def players
    # TODO: Turn this into a big query?
    ps = Set.new

    transfers.each do |transfer|
      if transfer.is_joining?
        ps << transfer.user
      else
        ps.delete(transfer.user)
      end
    end

    ps.to_a.sort! { |a, b| a.name.downcase <=> b.name.downcase }
  end
end
