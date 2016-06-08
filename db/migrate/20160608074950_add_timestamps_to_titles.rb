class AddTimestampsToTitles < ActiveRecord::Migration
  def change
    add_column(:titles, :created_at, :datetime)
    add_column(:titles, :updated_at, :datetime)
  end
end
