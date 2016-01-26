class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :name, null: false
      t.integer  :steam_id, limit: 8, null: false

      # Devise
      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.timestamps null: false
    end

    add_index :users, :steam_id, unique: true
    add_index :users, :name,     unique: true
  end
end
