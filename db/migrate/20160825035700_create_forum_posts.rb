class CreateForumPosts < ActiveRecord::Migration[5.0]
  def change
    create_table :forum_posts do |t|
      t.integer :thread_id,     null: false, index: true
      t.integer :created_by_id, null: false, index: true

      t.string :content, null: false

      t.timestamps null: false
    end

    add_foreign_key :forum_posts, :forum_threads, column: :thread_id
    add_foreign_key :forum_posts, :users,         column: :created_by_id
  end
end
