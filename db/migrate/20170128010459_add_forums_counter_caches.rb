class AddForumsCounterCaches < ActiveRecord::Migration[5.0]
  def change
    add_column :forums_topics,  :threads_count, :integer, null: false, default: 0
    Forums::Topic.select(:id).find_each do |topic|
      Forums::Topic.reset_counters(topic.id, :threads)
    end

    add_column :forums_threads, :posts_count,   :integer, null: false, default: 0
    Forums::Thread.select(:id).find_each do |thread|
      Forums::Thread.reset_counters(thread.id, :posts)
    end

    add_column :forums_posts,   :edits_count,   :integer, null: false, default: 0
    Forums::Post.select(:id).find_each do |post|
      Forums::Post.reset_counters(post.id, :edits)
    end
  end
end
