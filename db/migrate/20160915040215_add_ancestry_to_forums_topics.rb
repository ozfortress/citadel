class AddAncestryToForumsTopics < ActiveRecord::Migration[5.0]
  def change
    rename_column :forums_topics, :depth, :ancestry_depth
    remove_column :forums_topics, :parent_topic_id
    add_column :forums_topics, :ancestry, :string
    add_index :forums_topics, :ancestry
  end
end
