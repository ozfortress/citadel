module RosterPlayers
  extend ActiveSupport::Concern

  included do
    include Transfers
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

  private

  def players_db
    transfers.where(id: player_transfers(transfers, :user_id), is_joining: true)
             .joins(:user)
             .reorder('users.name')
             .includes(:user)
  end

  def players_local
    # TODO: Implement this properly. Right now its assuming #is_joining?
    transfers
  end
end
