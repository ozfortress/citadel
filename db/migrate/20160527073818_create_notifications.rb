class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.belongs_to :user, null: false, index: true, foreign_key: true
      t.boolean :read,    null: false, default: false
      t.string :message,  null: false
      t.string :link,     null: false

      t.timestamps null: false
    end
  end
end
