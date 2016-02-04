class CreateCompetitionTransfers < ActiveRecord::Migration
  def change
    create_table :competition_transfers do |t|
      t.belongs_to :competition_roster, index: true, foreign_key: true, null: false
      t.belongs_to :user, index: true, foreign_key: true, null: false

      t.boolean :is_joining, null: false
      t.boolean :approved, null: false

      t.timestamps null: false
    end
  end
end
