class CreateTitles < ActiveRecord::Migration[4.2]
  def change
    create_table :titles do |t|
      t.belongs_to :user,               index: true, foreign_key: true
      t.belongs_to :competition,        index: true, foreign_key: true
      t.belongs_to :competition_roster, index: true, foreign_key: true

      t.string :name, null: false
    end
  end
end
