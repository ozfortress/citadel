class CreateCompetitionMatchComms < ActiveRecord::Migration
  def change
    create_table :competition_match_comms do |t|
      t.belongs_to :competition_match, index: true, foreign_key: true
      t.belongs_to :user, index: true, foreign_key: true

      t.text :content, null: false

      t.timestamps null: false
    end
  end
end
