class CreateLeagueRosterTransferRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :league_roster_transfer_requests do |t|
      t.belongs_to :user,   index: true, foreign_key: true
      t.belongs_to :roster, index: true

      t.boolean :is_joining, null: false

      t.timestamps null: false
    end

    add_foreign_key :league_roster_transfer_requests, :league_rosters, column: :roster_id

    change_column_default :league_roster_transfers, :approved, from: false, to: true

    reversible do |dir|
      dir.up do
        create_transfer_requests_from_transfers
      end
    end
  end

  private

  def create_transfer_requests_from_transfers
    League::Roster::Transfer.where(approved: false).find_each do |transfer|
      League::Roster::TransferRequest.new(user: transfer.user,
                                          roster: transfer.roster,
                                          is_joining: transfer.is_joining?,
                                          created_at: transfer.created_at,
                                          updated_at: transfer.updated_at)
                                     .save!(validate: false)
      transfer.destroy!
    end
  end
end
