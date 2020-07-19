class AddDescriptionToForumsTopics < ActiveRecord::Migration[5.2]
  def change
    add_column :forums_topics, :description, :text, null: false, default: ''
    add_column :forums_topics, :description_render_cache, :text, null: false, default: ''
  end
end
