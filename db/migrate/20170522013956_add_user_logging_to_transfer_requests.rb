class AddUserLoggingToTransferRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :league_roster_transfer_requests, :created_by_id, :integer, index: true, null: true
    add_foreign_key :league_roster_transfer_requests, :users, column: :created_by_id

    add_column :league_roster_transfer_requests, :approved_by_id, :integer, index: true, null: true
    add_foreign_key :league_roster_transfer_requests, :users, column: :approved_by_id

    add_column :league_roster_transfer_requests, :denied_by_id, :integer, index: true, null: true
    add_foreign_key :league_roster_transfer_requests, :users, column: :denied_by_id

    add_index :league_roster_transfer_requests, [:approved_by_id, :denied_by_id],
              name: 'transfer_requests_on_approved_by_id_and_denied_by_id'

    add_column :league_roster_transfer_requests, :leaving_roster_id, :integer, null: true

    reversible do |dir|
      dir.up do
        user = User.first # Arbitrary user
        League::Roster::TransferRequest.find_each do |request|
          request.created_by = user
          if request.status == 1 # approved
            request.approved_by = user
          elsif request.status == 2 # denied
            request.denied_by = user
          end
          request.save(validate: false)
        end
      end

      dir.down do
        League::Roster::TransferRequest.find_each do |request|
          if request.approved_by.present? # approved
            request.update_attribute(:status, 1)
          elsif
            request.denied_by.present? # denied
            request.update_attribute(:status, 2)
          else # pending
            request.update_attribute(:status, 0)
          end
        end
      end
    end

    remove_column :league_roster_transfer_requests, :status, :integer
  end
end
