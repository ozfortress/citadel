class CreateCompetitions < ActiveRecord::Migration[4.2]
  def change
    create_table :competitions do |t|
      t.belongs_to :format, index: true, foreign_key: true
      t.string :name, null: false
      t.text :description, null: false

      t.timestamps null: false
    end
  end
end
