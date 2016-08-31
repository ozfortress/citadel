class CreateForumTopics < ActiveRecord::Migration[5.0]
  def change
    create_table :forum_topics do |t|
      t.integer :parent_topic_id, null: true,  index: true
      t.integer :created_by_id,   null: false, index: true

      t.string :name, null: false

      t.timestamps null: false
    end

    add_foreign_key :forum_topics, :forum_topics, column: :parent_topic_id
    add_foreign_key :forum_topics, :users,        column: :created_by_id
  end
end
