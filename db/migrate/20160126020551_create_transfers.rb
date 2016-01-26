class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :team, index: true, foreign_key: true

      t.boolean :is_joining?, null: false

      t.timestamps null: false
    end
  end
end
