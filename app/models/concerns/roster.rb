module Roster
  extend ActiveSupport::Concern

  def add_player!(user)
    transfers.create!(user: user, is_joining: true)
  end

  def remove_player!(user)
    transfers.create!(user: user, is_joining: false)
  end

  def on_roster?(user)
    players.where(user_id: user.id).exists?
  end

  def players
    if persisted?
      players_db
    else
      players_local
    end
  end

  def player_users
    players.map(&:user)
  end

  def player_ids
    players.map(&:user_id)
  end

  def player_ids=(value)
    value.each do |id|
      next if id.blank?

      transfers.new(user_id: id, is_joining: true)
    end
  end

  private

  def players_db
    t = transfers.select('DISTINCT ON(user_id) id')
                 .order(:user_id, created_at: :desc)

    transfers.where(id: t, is_joining: true)
             .joins(:user)
             .order('users.name')
             .includes(:user)
  end

  def players_local
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
