class CreateCompetitionRosters < ActiveRecord::Migration[4.2]
  def change
    create_table :competition_rosters do |t|
      t.belongs_to :team,     index: true, foreign_key: true, null: false
      t.belongs_to :division, index: true, foreign_key: true, null: false

      t.boolean :approved, null: false, default: false

      t.timestamps null: false
    end
  end
end
