class AddAPIKeyToVisits < ActiveRecord::Migration[5.0]
  def change
    add_column :visits, :api_key_id, :integer, null: true, index: true, default: nil
  end
end
