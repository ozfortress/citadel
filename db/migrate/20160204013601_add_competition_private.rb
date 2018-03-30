class AddCompetitionPrivate < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :private, :boolean, null: false
  end
end
