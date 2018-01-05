class AddDefaultLockedToForumsTopic < ActiveRecord::Migration[5.0]
  def change
    add_column :forums_topics, :default_locked, :boolean, default: false
  end
end
