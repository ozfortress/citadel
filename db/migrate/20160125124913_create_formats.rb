class CreateFormats < ActiveRecord::Migration[4.2]
  def change
    create_table :formats do |t|
      t.belongs_to :game, index: true, foreign_key: true

      t.string     :name,         null: false
      t.text       :description,  null: false
      t.integer    :player_count, null: false

      t.timestamps null: false
    end

    add_index :formats, :name, unique: true
  end
end
