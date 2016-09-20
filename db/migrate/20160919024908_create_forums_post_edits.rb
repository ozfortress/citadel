class CreateForumsPostEdits < ActiveRecord::Migration[5.0]
  def change
    create_table :forums_post_edits do |t|
      t.integer :post_id,       null: false, index: true
      t.integer :created_by_id, null: false, index: true

      t.string :content, null: false

      t.timestamps null: false
    end

    add_foreign_key :forums_post_edits, :forums_posts, column: :post_id
    add_foreign_key :forums_post_edits, :users,        column: :created_by_id
  end
end
