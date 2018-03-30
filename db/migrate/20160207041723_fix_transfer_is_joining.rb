class FixTransferIsJoining < ActiveRecord::Migration[4.2]
  def change
    rename_column :transfers, :is_joining?, :is_joining
  end
end
