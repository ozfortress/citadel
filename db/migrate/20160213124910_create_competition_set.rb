class CreateCompetitionSet < ActiveRecord::Migration[4.2]
  def change
    create_table :competition_sets do |t|
      t.belongs_to :competition_match, index: true, foreign_key: true
      t.belongs_to :map, index: true, foreign_key: true

      t.integer :home_team_score, null: false
      t.integer :away_team_score, null: false

      t.timestamps null: false
    end
  end
end
