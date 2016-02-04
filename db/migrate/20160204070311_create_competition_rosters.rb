class CreateCompetitionRosters < ActiveRecord::Migration
  def change
    create_table :competition_rosters do |t|
      t.belongs_to :team,     index: true, foreign_key: true, null: false
      t.belongs_to :division, index: true, foreign_key: true, null: false

      t.integer :points,   null: false, default: 0
      t.boolean :approved, null: false, default: false

      t.timestamps null: false
    end
  end
end
