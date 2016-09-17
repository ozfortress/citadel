class CreateForumsSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :forums_subscriptions do |t|
      t.belongs_to :user,      null: false, index: true, foreign_key: true
      t.integer    :topic_id,  null: true,  index: true
      t.integer    :thread_id, null: true,  index: true

      t.timestamps
    end

    add_foreign_key :forums_subscriptions, :forums_topics,  column: :topic_id
    add_foreign_key :forums_subscriptions, :forums_threads, column: :thread_id
  end
end
