class AddStatusToLeagueRosterTransferRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :league_roster_transfer_requests, :status, :integer, null: false, default: 0
  end
end
