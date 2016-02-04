class AddCompetitionPrivate < ActiveRecord::Migration
  def change
    add_column :competitions, :private, :boolean, null: false
  end
end
