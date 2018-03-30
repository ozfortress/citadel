class CreateDivisions < ActiveRecord::Migration[4.2]
  def change
    create_table :divisions do |t|
      t.belongs_to :competition, index: true, foreign_key: true

      t.string :name,        null: false
      t.text   :description, null: false

      t.timestamps null: false
    end
  end
end
