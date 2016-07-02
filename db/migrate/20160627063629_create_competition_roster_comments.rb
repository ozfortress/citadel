class CreateCompetitionRosterComments < ActiveRecord::Migration
  def change
    create_table :competition_roster_comments do |t|
      t.belongs_to :competition_roster, index: true, foreign_key: true, null: false
      t.belongs_to :user, index: true, foreign_key: true

      t.text :content, null: false

      t.timestamps null: false
    end
  end
end
