class AddBadgeToTitles < ActiveRecord::Migration[4.2]
  def change
    add_column :titles, :badge, :string
  end
end
