class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.belongs_to :format,      null: false
      t.string     :name,        null: false
      t.text       :description, null: false

      t.timestamps null: false
    end

    add_index :teams, :name, unique: true
  end
end
