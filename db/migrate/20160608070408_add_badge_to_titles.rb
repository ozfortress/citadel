class AddBadgeToTitles < ActiveRecord::Migration
  def change
    add_column :titles, :badge, :string
  end
end
