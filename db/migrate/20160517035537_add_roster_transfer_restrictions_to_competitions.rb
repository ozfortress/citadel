class AddRosterTransferRestrictionsToCompetitions < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :transfers_require_approval, :boolean, null: false, default: true
  end
end
