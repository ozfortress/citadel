class CreateCompetitionTransfers < ActiveRecord::Migration
  def change
    create_table :competition_transfers do |t|
      t.belongs_to :competition_roster, index: true, foreign_key: true
      t.belongs_to :user, index: true, foreign_key: true

      t.boolean :is_joining
      t.boolean :approved

      t.timestamps null: false
    end
  end
end
