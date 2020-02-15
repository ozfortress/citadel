class RenameForumTopicThreadCountToVisibleThreadCount < ActiveRecord::Migration[5.2]
  def change
    rename_column :forums_topics, :threads_count, :visible_threads_count

    Forums::Thread.counter_culture_fix_counts only: :topic
  end
end
