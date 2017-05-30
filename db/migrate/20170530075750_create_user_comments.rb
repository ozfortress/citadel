class CreateUserComments < ActiveRecord::Migration[5.0]
  def change
    create_table :user_comments do |t|
      t.integer :user_id, index: true, null: false
      t.integer :created_by_id, null: false

      t.text :content, null: false
      t.text :content_render_cache, null: false

      t.timestamps null: false
    end

    add_foreign_key :user_comments, :users, column: :user_id
    add_foreign_key :user_comments, :users, column: :created_by_id
  end
end
