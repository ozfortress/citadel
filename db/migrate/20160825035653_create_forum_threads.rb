class CreateForumThreads < ActiveRecord::Migration[5.0]
  def change
    create_table :forum_threads do |t|
      t.integer :topic_id,      null: true, index: true
      t.integer :created_by_id, null: false, index: true

      t.string :title, null: false

      t.timestamps null: false
    end

    add_foreign_key :forum_threads, :forum_topics, column: :topic_id
    add_foreign_key :forum_threads, :users,        column: :created_by_id
  end
end
