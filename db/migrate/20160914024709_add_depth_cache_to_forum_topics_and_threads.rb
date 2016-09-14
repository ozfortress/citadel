class AddDepthCacheToForumTopicsAndThreads < ActiveRecord::Migration[5.0]
  def change
    add_column :forums_topics, :depth, :integer, default: 0, null: false

    Forums::Topic.find_each do |topic|
      topic.update!(depth: topic.ancestors.count)
    end

    add_column :forums_threads, :depth, :integer, default: 0, null: false

    Forums::Thread.find_each do |thread|
      thread.update!(depth: thread.ancestors.count)
    end
  end
end
