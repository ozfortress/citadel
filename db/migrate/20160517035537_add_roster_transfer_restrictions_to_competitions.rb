class AddRosterTransferRestrictionsToCompetitions < ActiveRecord::Migration
  def change
    add_column :competitions, :transfers_require_approval, :boolean, null: false, default: true
  end
end
