class CreateAPIKeys < ActiveRecord::Migration[5.0]
  def change
    create_table :api_keys do |t|
      t.string :name, unique: true, null: true,  index: true
      t.string :key,  unique: true, null: false, index: true

      t.belongs_to :user, null: true, index: true

      t.timestamps
    end
  end
end
