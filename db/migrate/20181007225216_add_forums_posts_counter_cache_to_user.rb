class AddForumsPostsCounterCacheToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :forums_posts_count, :integer, null: false, default: 0
    add_column :users, :public_forums_posts_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        ActiveRecord::Base.connection.execute(<<-SQL)
          UPDATE users
          SET public_forums_posts_count = (
                SELECT COUNT(1) FROM forums_posts INNER JOIN forums_threads ON forums_threads.id = thread_id
                WHERE forums_posts.created_by_id = users.id AND NOT hidden),
              forums_posts_count = (SELECT COUNT(1) FROM forums_posts WHERE created_by_id = users.id)
        SQL
      end
    end
  end
end
