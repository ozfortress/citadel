class CreateFormats < ActiveRecord::Migration
  def change
    create_table :formats do |t|
      t.belongs_to :game,         null: false
      t.string     :name,         null: false
      t.text       :description,  null: false
      t.integer    :player_count, null: false

      t.timestamps null: false
    end

    add_index :formats, :name, unique: true
  end
end
