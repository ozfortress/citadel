class FixTransferIsJoining < ActiveRecord::Migration
  def change
    rename_column :transfers, :is_joining?, :is_joining
  end
end
