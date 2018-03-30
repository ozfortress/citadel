class CreateCompetitionMatches < ActiveRecord::Migration[4.2]
  def change
    create_table :competition_matches do |t|
      # t.belongs_to doesn't allow you to set the column name for whatever reason
      t.integer :home_team_id
      t.integer :away_team_id

      t.integer :status, null: false

      t.timestamps null: false
    end

    add_index :competition_matches, :home_team_id
    add_foreign_key :competition_matches, :competition_rosters, column: :home_team_id
    add_index :competition_matches, :away_team_id
    add_foreign_key :competition_matches, :competition_rosters, column: :away_team_id
  end
end
