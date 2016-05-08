module Roster
  extend ActiveSupport::Concern

  included do
    include RosterPlayers
  end

  def add_player!(user)
    transfers.create!(user: user, is_joining: true)
  end

  def remove_player!(user)
    transfers.create!(user: user, is_joining: false)
  end

  def player_ids=(value)
    value.each do |id|
      next if id.blank?

      transfers.new(user_id: id, is_joining: true)
    end
  end
end
