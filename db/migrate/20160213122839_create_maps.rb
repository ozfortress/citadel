class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.belongs_to :game, index: true, foreign_key: true

      t.string :name,        null: false
      t.text   :description, null: false

      t.timestamps null: false
    end
  end
end
