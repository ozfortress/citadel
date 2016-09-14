class AddForumsPermissionsAndOptions < ActiveRecord::Migration[5.0]
  include Auth::MigrationHelper

  def change
    add_column :forum_topics,  :locked,         :boolean, default: false
    add_column :forum_topics,  :pinned,         :boolean, default: false
    add_column :forum_topics,  :hidden,         :boolean, default: false
    add_column :forum_topics,  :isolated,       :boolean, default: false
    add_column :forum_topics,  :default_hidden, :boolean, default: false
    add_column :forum_threads, :locked,         :boolean, default: false
    add_column :forum_threads, :pinned,         :boolean, default: false
    add_column :forum_threads, :hidden,         :boolean, default: false
    add_action_auth :user, :manage, :forum_topic
    add_action_auth :user, :edit,   :forum_thread
    add_action_auth :user, :manage, :forum_thread
  end
end
