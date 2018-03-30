class CreateAhoyEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :ahoy_events do |t|
      t.integer :visit_id

      # user
      t.integer :user_id
      # add t.string :user_type if polymorphic

      t.string :name
      t.string :method
      t.string :ip
      t.string :uri
      t.json :properties
      t.timestamp :time
    end

    add_index :ahoy_events, [:visit_id, :name]
    add_index :ahoy_events, [:user_id, :name]
    add_index :ahoy_events, [:name, :time]
    add_index :ahoy_events, [:method]
    add_index :ahoy_events, [:ip]
    add_index :ahoy_events, [:uri]
  end
end
