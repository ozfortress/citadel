class CreateCompetitionTiebreaker < ActiveRecord::Migration[4.2]
  def change
    create_table :competition_tiebreakers do |t|
      t.belongs_to :competition, index: true, foreign_key: true
      t.integer :kind, null: false
    end
  end
end
