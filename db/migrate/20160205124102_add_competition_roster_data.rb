class AddCompetitionRosterData < ActiveRecord::Migration
  def change
    add_column :competition_rosters, :name,        :string, null: false
    add_column :competition_rosters, :description, :text,   null: false
  end
end
