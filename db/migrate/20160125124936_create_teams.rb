class CreateTeams < ActiveRecord::Migration[4.2]
  def change
    create_table :teams do |t|
      t.belongs_to :format, index: true, foreign_key: true

      t.string     :name,        null: false
      t.text       :description, null: false

      t.timestamps null: false
    end

    add_index :teams, :name, unique: true
  end
end
