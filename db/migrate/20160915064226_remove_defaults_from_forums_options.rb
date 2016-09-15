class RemoveDefaultsFromForumsOptions < ActiveRecord::Migration[5.0]
  def change
    change_column_default :forums_topics,  :locked,         nil
    change_column_default :forums_topics,  :pinned,         nil
    change_column_default :forums_topics,  :hidden,         nil
    change_column_default :forums_topics,  :isolated,       nil
    change_column_default :forums_topics,  :default_hidden, nil
    change_column_default :forums_threads, :locked,         nil
    change_column_default :forums_threads, :pinned,         nil
    change_column_default :forums_threads, :hidden,         nil
  end
end
