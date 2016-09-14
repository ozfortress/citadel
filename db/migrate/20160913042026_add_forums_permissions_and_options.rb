class AddForumsPermissionsAndOptions < ActiveRecord::Migration[5.0]
  include Auth::MigrationHelper

  def change
    rename_table :forum_topics, :forums_topics
    rename_table :forum_threads, :forums_threads
    rename_table :forum_posts, :forums_posts
    add_column :forums_topics,  :locked,         :boolean, default: false
    add_column :forums_topics,  :pinned,         :boolean, default: false
    add_column :forums_topics,  :hidden,         :boolean, default: false
    add_column :forums_topics,  :isolated,       :boolean, default: false
    add_column :forums_topics,  :default_hidden, :boolean, default: false
    add_column :forums_threads, :locked,         :boolean, default: false
    add_column :forums_threads, :pinned,         :boolean, default: false
    add_column :forums_threads, :hidden,         :boolean, default: false
    add_action_auth :user, :manage, :forums_topic
    add_action_auth :user, :manage, :forums_thread
  end
end
