class AddDepthCacheToForumTopicsAndThreads < ActiveRecord::Migration[5.0]
  def change
    add_column :forums_topics, :depth, :integer, default: 0, null: false

    Forums::Topic.find_each do |topic|
      topic.update!(depth: topic.parent_topics.count)
    end

    add_column :forums_threads, :depth, :integer, default: 0, null: false

    Forums::Thread.find_each do |thread|
      thread.update!(depth: thread.parent_topics.count)
    end
  end
end
