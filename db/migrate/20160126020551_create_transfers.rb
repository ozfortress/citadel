class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.belongs_to :user,        null: false
      t.belongs_to :team,        null: false
      t.boolean    :is_joining?, null: false

      t.timestamps null: false
    end
  end
end
