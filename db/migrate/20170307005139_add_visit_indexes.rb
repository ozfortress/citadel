class AddVisitIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :visits, :started_at
    add_index :visits, :browser
    add_index :visits, :os
    add_index :visits, :referring_domain
  end
end
